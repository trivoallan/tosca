class AddConstraints < ActiveRecord::Migration
  def self.up
    options = {:id => false, :options => 'ENGINE=MyISAM DEFAULT CHARSET=utf8'} 

    add_column :appels, :contrat_id, :integer, :null => false
    add_column :appels, :demande_id, :integer, :null => true

    add_index :appels, :contrat_id

    add_column :contrats, :astreinte, :boolean, :default => false, :null => false
    add_column :supports, :duree_intervention, :integer, :null => true
    
  end

  def self.down
    remove_column :contrats, :astreinte
    remove_column :supports, :duree_intervention
    remove_column :appels, :contrat_id
    remove_column :appels, :demande_id
  end
end
