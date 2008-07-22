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
  end
  class Paquet < ActiveRecord::Base
    belongs_to :logiciel
    belongs_to :contract, :counter_cache => true
    belongs_to :mainteneur

    has_many :changelogs, :dependent => :destroy
    has_many :binaires, :dependent => :destroy, :include => :paquets
    has_and_belongs_to_many :contributions
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
      t.string :version
    end
    add_index :versions, :logiciel_id

    create_table :releases do |t|
      t.integer :id, :version_id, :contract_id
      t.string :release, :default => '0'
      t.boolean :packaged, :default => false
      t.boolean :inactive, :default => false
    end
    add_index :releases, :version_id
    add_index :releases, :contract_id

    create_table :contributions_versions, :id => false do |t|
      t.integer :contribution_id, :version_id
    end
    add_index :contributions_versions, :contribution_id
    add_index :contributions_versions, :version_id

    package = Conteneur.find(:all,
      :conditions => [ "name IN (?)", %w(rpm deb pkg) ]).collect { |c| c.id }

    Paquet.find(:all, :order => "logiciel_id ASC, version ASC").each do |p|
      version = Version.new do |v|
        v.logiciel_id = p.logiciel_id
        v.version = p.version
      end
      version.save

      p.contributions.each do |c|
        c.versions << version
      end

      release = Release.new do |r|
        r.version_id = version.id
        r.contract_id = p.contract_id
        r.release = p.release ? p.release : '0'
        r.packaged = true if package.include? p.conteneur_id
        r.inactive = !p.active
      end
      release.save
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
