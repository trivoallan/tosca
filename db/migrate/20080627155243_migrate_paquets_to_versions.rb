class MigratePaquetsToVersions < ActiveRecord::Migration
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
    
    create_table :releases do |t|
      t.integer :id, :version_id, :changelog_id, :contract_id
      t.string :release
      t.boolean :packaged, :default => false
      t.boolean :active
    end
    
    create_table :contributions_versions, :id => false do |t|
      t.integer :contribution_id, :version_id
    end

    package = Conteneur.find(:all, 
                              :conditions => [ "name = ? or name = ? or name = ?", "rpm", "deb", "pkg"]).collect { |c| c.id }
    
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
        r.release = p.release ? p.release : "0"
        r.packaged = true if package.include? p.conteneur_id
      end 
      release.save
    end
    
    drop_table :contributions_paquets
    drop_table :paquets
  end

  def self.down
#    ActiveRecord::IrreversibleMigration
  end
end
