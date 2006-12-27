class AlterBinaire < ActiveRecord::Migration
  def self.up
    drop_table :binaires
    rename_table :paquets_binaires, :binaires
    rename_column :fichiers_binaires, :paquet_binaire_id, :binaire_id
    rename_table :fichiers_binaires, :fichierbinaires

    rename_column :socles, :paquets_count, :binaires_count

    create_table :binaires_demandes, :id => false do |t|
      t.column :binaire_id, :integer
      t.column :demande_id, :integer
    end
    add_index :binaires_demandes, :binaire_id
    add_index :binaires_demandes, :demande_id

    create_table :binaires_correctifs, :id => false do |t|
      t.column :binaire_id, :integer
      t.column :correctif_id, :integer
    end
    add_index :binaires_correctifs, :binaire_id
    add_index :binaires_correctifs, :correctif_id
    
    add_column :binaires, :archive, :string
    add_column :binaires, :socle_id, :integer
    add_column :binaires, :fichierbinaires_count, :integer

    update('UPDATE binaires b SET b.socle_id=(' + 
             'SELECT socle_id FROM paquets p WHERE p.id=b.paquet_id);')
    remove_column :paquets, :socle_id

  end

  def self.down
#     add_column :paquets, :socle_id, :integer
#     add_index :paquets, :socle_id
#     update('UPDATE paquets p SET p.socle_id=(' + 
#              'SELECT socle_id FROM binaires b WHERE p.id=b.paquet_id LIMIT 1);')

#     remove_column :binaires, :archive
#     remove_column :binaires, :socle_id
#     remove_column :binaires, :fichierbinaires_count
    rename_table :binaires, :paquets_binaires
    rename_table :fichierbinaires, :fichiers_binaires
    rename_column :fichiers_binaires, :binaire_id, :paquet_binaire_id

    rename_column :socles, :binaires_count, :paquets_count

    drop_table :binaires_demandes

    create_table 'binaires' do |t|
      t.column :fichier, :string, :null => false
      t.column :correctif_id, :integer, :null => false
    end
    add_index(:binaires, :correctif_id)

    drop_table :binaires_correctifs


  end
end
