class RemoveFilesForPackagesAndBinaries < ActiveRecord::Migration
  def self.up
    drop_table :fichierbinaires
    drop_table :fichiers

    remove_column :binaires, :fichierbinaires_count
    remove_column :paquets, :fichiers_count
  end

  def self.down
    create_table "fichiers", :force => true do |t|
      t.column "paquet_id", :integer, :default => 0,  :null => false
      t.column "chemin",    :string,  :default => ""
      t.column "taille",    :integer, :default => 0,  :null => false
    end
    add_index "fichiers", ["paquet_id"]

    create_table "fichierbinaires", :force => true do |t|
      t.column "binaire_id", :integer
      t.column "chemin",     :string
      t.column "taille",     :integer
    end
    add_index "fichierbinaires", ["binaire_id"]

    add_column :binaires, :fichierbinaires_count, :integer
    add_column :paquets, :fichiers_count, :integer
  end
end
