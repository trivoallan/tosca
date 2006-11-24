#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class CreateEtatreversement < ActiveRecord::Migration
  def self.up
    # les états possibles d'un reversement
    create_table :etatreversements, :id => false do |t|
      t.column :nom, :string, :null => false
      t.column :description, :text, :null => false
      t.column :created_on, :timestamp, :null => false
      t.column :updated_on, :timestamp, :null => false
    end

    # un reversement a maintenant un état
    add_column :reversements, :etatreversement_id, :integer, :null => false

  end

  def self.down
    drop_table :etatreversements

    remove_column :reversements, :etatreversement_id
  end
end
