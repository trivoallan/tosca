#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class CreateInteractions < ActiveRecord::Migration
  def self.up
    create_table :interactions do |t|
      t.column :url_de_suivi, :text, :default => "", :null => false
      t.column :temps_passe, :float, :default => 0.0, :null => false
      t.column :resume, :string, :null => false
      t.column :description, :text, :null => false
      t.column :logiciel_id, :integer, :null => false
      t.column :ingenieur_id, :integer, :null => false
      t.column :created_on, :timestamp, :null => false
      t.column :updated_on, :timestamp, :null => false
    end
    add_index :interactions, :logiciel_id

    # un reversement est maintenant lié à une interaction
    add_column :reversements, :interaction_id, :integer, :null => false
    add_index :reversements, :interaction_id

    # l'url est dans Interaction
    remove_column :reversements, :url_de_suivi

    # 'clos' ne veut pas dire 'accepté'
    remove_column :reversements, :accepte_le
    add_column :reversements, :cloture, :timestamp
    
    # Un reversement n'a plus besoin de nom
    # il y le résumé de son interaction
    remove_column :reversements, :nom
  end

  def self.down
    drop_table :interactions

    remove_column :reversements, :interaction_id
    add_column :reversements, :url_de_suivi, :text, :default => "", :null => false
    add_column :reversements, :accepte_le, :timestamp
    remove_column :reversements, :cloture
    add_column :reversements, :nom
  end
end
