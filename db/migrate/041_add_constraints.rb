class AddConstraints < ActiveRecord::Migration
  def self.up
    options =  { :id => false, :options => 'ENGINE=MyISAM' }
    create_table :appels_demandes, options do |t|
      t.column :appel_id, :integer, :null => false
      t.column :demande_id, :integer, :null => false
    end

    add_index :appels_demandes, :appel_id
    add_index :appels_demandes, :demande_id
    

    add_columns :appels, :contrat_id, :integer, :null => false
    add_index :appels, :contrat_id

    add_column :contrats, :astreinte, :boolean, :default => false, :null => false
    add_column :support, :duree_intervention, :integer, :null => true
    
  end

  def self.down
    drop_table :appels_demandes
    remove_column :contrats, :astreinte
    remove_column :support, :duree_intervention
    remove_column :appels, :contrat_id
  end
end
