#For moving files
require 'fileutils'

class MigratePaquetsToVersions < ActiveRecord::Migration

  class Conteneur < ActiveRecord::Base
  end

  class Release < ActiveRecord::Base
  end

  class Contribution < ActiveRecord::Base
    has_many :versions
  end

  class Version < ActiveRecord::Base
    belongs_to :contribution
    has_many :releases
    has_and_belongs_to_many :contracts
  end

  class Paquet < ActiveRecord::Base
    belongs_to :logiciel
    belongs_to :contract, :counter_cache => true
    belongs_to :mainteneur

    has_many :changelogs, :dependent => :destroy
    has_many :binaires, :dependent => :destroy, :include => :paquets
    has_and_belongs_to_many :contributions
  end

  class Binaire < ActiveRecord::Base
    belongs_to :paquet
  end

  class Release < ActiveRecord::Base
    belongs_to :version
    belongs_to :contract
  end

  class Logiciel < ActiveRecord::Base
    has_many :versions, :order => "name DESC", :dependent => :destroy
  end

  def self.up
    #There is no changelog in the database
    rename_column :changelogs, :paquet_id, :release_id

    #No more used
    drop_table :dependances

    #Not used
    remove_column :contracts, :paquets_count

    create_table :versions do |t|
      t.integer :id, :logiciel_id
      t.string :name
    end
    add_index :versions, :logiciel_id

    create_table :releases do |t|
      t.integer :id, :version_id, :contract_id
      t.string :name, :default => '0'
      t.boolean :packaged, :default => false
      t.boolean :inactive, :default => false
    end
    add_index :releases, :version_id
    add_index :releases, :contract_id

    create_table :contracts_versions, :id => false do |t|
      t.integer :contract_id, :version_id
    end

    create_table :contributions_versions, :id => false do |t|
      t.integer :contribution_id, :version_id
    end
    add_index :contributions_versions, :contribution_id
    add_index :contributions_versions, :version_id

    create_table :archives do |t|
      t.string :name
      t.integer :size, :release_id
    end
    add_index :archives, :release_id

    package = Conteneur.find(:all,
      :conditions => [ "name IN (?)", %w(rpm deb pkg) ]).collect { |c| c.id }
    puts "Conteneur found"

    Paquet.find(:all, :order => "logiciel_id ASC, version ASC").each do |p|
      version = Version.new do |v|
        v.logiciel_id = p.logiciel_id
        v.name = p.version
      end
      version.save!

      p.contributions.each do |c|
        c.versions << version
      end

      release = Release.new do |r|
        r.version_id = version.id
        r.contract_id = p.contract_id
        r.name = p.release ? p.release : '0'
        r.packaged = true if package.include? p.conteneur_id
        r.inactive = !p.active
      end
      release.save!
    end
    puts "Migrating Paquet done"

    Version.find(:all).each do |v|
      v.releases.each { |r|
        v.contracts << r.contract unless v.contracts.include? r.contract
      }
      v.save!
    end
    puts "Migrating contracts for release done"

    #Remove duplicate versions
    last_version = Version.new
    Version.find(:all, :order => 'logiciel_id, name').each do |v|
      if v.name == last_version.name and v.logiciel_id == last_version.logiciel_id
        v.releases.each do |r|
          r.version_id = last_version.id
          r.save
        end
        last_version.contracts << v.contracts
        last_version.save
        v.destroy
      else
        last_version = v
      end
    end
    puts "Remove duplicate Versions done"
    
    #Remove duplicate releases
    last_release = Release.new
    Release.find(:all, :order => 'contract_id, version_id, name').each do |r|
      if r.version_id == last_release.version_id and 
          r.contract_id == last_release.contract_id and 
          r.name == last_release.name
        r.destroy
      else
        last_release = r
      end
    end
    puts "Remove duplicate Releases done"
    
    old_archive_path = File.join(RAILS_ROOT, "files", "binaire", "archive")
    new_archive_path = File.join(RAILS_ROOT, "files", "archive", "name")
    Binaire.find(:all, :conditions => "archive is not null").each do |b|
      version = b.paquet.version 
      logiciel = Logiciel.find(b.paquet.logiciel_id)
      version = logiciel.versions.find(:all, :conditions => { :name => b.paquet.version })
      if version.size != 1
        puts "Too much versions #{logiciel.name}, ##{logiciel.id}, ##{b.id}"
      else
        version = version.first
        release = version.releases.find(:all, :conditions => { :name => b.paquet.release })
        release.each do |r|
          archive = Archive.new do |a|
            a.name = b.archive
            a.release_id = release.id
          end
          archive.save

          new_path = File.join(new_archive_path, archive.id.to_s)
          old_path = File.join(old_archive_path, b.id.to_s, "*")
          FileUtils.mkdir_p(new_path)
          puts "Copy from #{old_path} to #{new_path}"
          FileUtils.cp_r(old_path, new_path)
        end
      end
    end

    drop_table :contributions_paquets
    drop_table :paquets
    drop_table :conteneurs
    drop_table :binaires
    drop_table :binaires_contributions
  end

  def self.down
    # let's move forward
    ActiveRecord::IrreversibleMigration
  end
end
