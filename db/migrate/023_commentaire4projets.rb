#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Commentaire4projets < ActiveRecord::Migration
  def self.up
    create_table :echanges do |t|
      t.column :tache_id, :integer, :null => false
      t.column :auteur_id, :integer, :null => false #identifiant_id
      t.column :piecejointe_id, :integer
      t.column :etape_id, :integer
      t.column :corps, :text

      t.column :created_on, :timestamp
      t.column :updated_on, :timestamp
      t.column :prive, :boolean
    end

    add_index :echanges, :tache_id
    add_index :echanges, :auteur_id
    add_index :echanges, :piecejointe_id
    add_index :echanges, :etape_id
  end

  def self.down
    drop_table :echanges
  end
end
