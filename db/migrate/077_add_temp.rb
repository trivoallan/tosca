#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class AddTemp < ActiveRecord::Migration
  def self.up
    create_table :temps do |t|
      t.column :contournement, :float, :null => true
      t.column :correction, :float, :null => true
      t.column :ecoule, :float, :null => true
      t.column :rappel, :float, :null => true
    end
    
    add_column :demandes, :temps_id, :integer, :null =>true
  end

  def self.down
    remove_column :demandes, :temps_id
    drop_table :temps
    
  end
end
