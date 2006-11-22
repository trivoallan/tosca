#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class RefactoringCorrectifs < ActiveRecord::Migration
  def self.up
    create_table :correctifs do |t|
      t.column :nom, :string, :null => false
      t.column :description, :text, :null => false
      t.column :patch, :string, :null => false
      t.column :created_on, :timestamp, :null => false
      t.column :updated_on, :timestamp, :null => false
    end
    
    create_table :binaires do |t|
      t.column :fichier, :string, :null => false
      t.column :correctif_id, :integer, :null => false
    end
    add_index(:binaires, :correctif_id)


    add_column :demandes, :correctif_id,
    :integer, :null => true
    Demande.drop_versioned_table
    Demande.create_versioned_table
    add_index(:demandes, :correctif_id)
   
    add_column :reversements, :correctif_id,
    :integer, :null => false
  end

  def self.down
    drop_table :binaires
    drop_table :correctifs

    remove_column :demandes, :correctif_id 
    remove_column :reversements, :correctif_id 
  end
end
