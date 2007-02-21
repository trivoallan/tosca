#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Projets < ActiveRecord::Migration
  def self.up
    create_table :projets do |t|
      t.column :created_on, :timestamp, :null => false
      t.column :updated_on, :timestamp, :null => false
      t.column :resume, :string
      t.column :chrono, :integer, :null => false
      t.column :description, :text
    end

    add_index :projets, :chrono

    create_table :logiciels_projets, :id => false  do |t|
      t.column :logiciel_id, :integer, :null => false
      t.column :projet_id, :integer, :null => false
    end
    add_index :logiciels_projets, :logiciel_id
    add_index :logiciels_projets, :projet_id

    create_table :beneficiaires_projets, :id => false  do |t|
      t.column :beneficiaire_id, :integer, :null => false
      t.column :projet_id, :integer, :null => false
    end
    add_index :beneficiaires_projets, :beneficiaire_id
    add_index :beneficiaires_projets, :projet_id

    create_table :ingenieurs_projets, :id => false  do |t|
      t.column :ingenieur_id, :integer, :null => false
      t.column :projet_id, :integer, :null => false
    end
    add_index :ingenieurs_projets, :ingenieur_id
    add_index :ingenieurs_projets, :projet_id

  end

  def self.down
    #drop aussi les index
    drop_table :projets 
    drop table :logiciels_projets
    drop_table :beneficiaires_projets
    drop_table :ingenieurs_projets
  end
end
