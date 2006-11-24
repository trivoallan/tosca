#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class CreateInteractions < ActiveRecord::Migration
  def self.up
    create_table :interactions, :id => false do |t|
      t.column :nom, :string, :null => false
      t.column :url, :string, :null => false
      t.column :logiciel_id, :integer, :null => false
      t.column :ingenieur_id, :integer, :null => false
      t.column :description, :text, :null => false
      t.column :temps_passe, :float, :null => false
      t.column :created_on, :timestamp, :null => false
      t.column :updated_on, :timestamp, :null => false
    end
    add_index(:interactions, :logiciel_id)
  end

  def self.down
    drop_table :interactions
  end
end
