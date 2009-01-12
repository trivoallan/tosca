#
# Copyright (c) 2006-2009 Linagora
#
# This file is part of Tosca
#
# Tosca is free software, you can redistribute it and/or modify
# it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
# Tosca is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
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

  class Contract < ActiveRecord::Base
     has_and_belongs_to_many :versions
  end

  def self.up
    remove_column :demandes, :binaire_id
    add_column :demandes, :version_id, :integer
    add_column :demandes, :release_id, :integer
    add_index :demandes, :version_id
    add_index :demandes, :release_id

    #There is no changelog in the database
    rename_column :changelogs, :paquet_id, :release_id

    #No more used
    drop_table :dependances

    #Not used
    remove_column :contracts, :paquets_count

    create_table :versions do |t|
      t.integer :logiciel_id
      t.string :name
      t.boolean :generic
    end
    add_index :versions, :logiciel_id

    create_table :releases do |t|
      t.integer :version_id, :contract_id
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
      t.string :file
      t.integer :size, :release_id
    end
    add_index :archives, :release_id

    package = Conteneur.all(
      :conditions => [ "name IN (?)", %w(rpm deb pkg) ]).collect { |c| c.id }
    puts "Conteneur found"

    Paquet.all(:order => "logiciel_id ASC, version ASC").each do |p|
      version = Version.create(:logiciel_id => p.logiciel_id, :name => p.version)
      # an id is needed before saving a n-n relationship
      version.contracts << p.contract
      version.save!

      p.contributions.each do |c|
        c.versions << version
        c.save!
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

    #Remove duplicate versions
    last_version = Version.new
    Version.all(:order => 'logiciel_id, name').each do |v|
      if v.name == last_version.name and v.logiciel_id == last_version.logiciel_id
        v.releases.each do |r|
          r.version_id = last_version.id
          r.save
        end
        last_version.contracts.concat(v.contracts).uniq!
        last_version.save!
        v.destroy
      else
        last_version = v
      end
    end
    puts "Remove duplicate Versions done"

    # We are forced to make it in two pass, since there's a strange caching
    # model for saving in rails 2.1
    Contract.all.each do |c|
      c.versions.uniq!
      c.save!
    end
    puts "Remove duplicate versions of Contracts"

    #Generic versions
    Version.all.each do |v|
      case v.name
      when /\.[xX]/
        v.name = v.name.gsub(/\.[xX]/, "")
        v.generic = true
      when /^[xX]/
        v.name = ""
        v.generic = true
      else
        #Something to do ?
      end
      v.save!
    end

    #Remove duplicate releases
    last_release = Release.new
    Release.all(:order => 'contract_id, version_id, name').each do |r|
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
    new_archive_path = File.join(RAILS_ROOT, "files", "archive", "file")
    Binaire.all(:conditions => "archive is not null").each do |b|
      logiciel = Logiciel.find(b.paquet.logiciel_id)
      version = logiciel.versions.all(:conditions => { :name => b.paquet.version })
      if version.size != 1
        puts "Too much versions #{logiciel.name}, ##{logiciel.id}, ##{b.id}"
      else
        version = version.first
        release = version.releases.all(:conditions => { :name => b.paquet.release,
          :contract_id => b.paquet.contract_id })

        release.each do |r|
          File.open(File.join(old_archive_path, b.id.to_s, b.archive)) do |f|
            Archive.create(:file => f, :release_id => release.id)
          end
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
