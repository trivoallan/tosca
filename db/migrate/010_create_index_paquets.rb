#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class CreateIndexPaquets < ActiveRecord::Migration
  def self.up
    add_index :paquets, :logiciel_id
    add_index :paquets, :conteneur_id
    add_index :paquets, :arch_id
    add_index :paquets, :paquet_id
    add_index :paquets, :distributeur_id
    add_index :paquets, :mainteneur_id
    add_index :paquets, :contrat_id
    add_index :paquets, :socle_id
    add_index :paquets, :fournisseur_id

  end

  def self.down
    remove_index :paquets, :logiciel_id
    remove_index :paquets, :conteneur_id
    remove_index :paquets, :arch_id
    remove_index :paquets, :paquet_id
    remove_index :paquets, :distributeur_id
    remove_index :paquets, :mainteneur_id
    remove_index :paquets, :contrat_id
    remove_index :paquets, :socle_id
    remove_index :paquets, :fournisseur_id
  end
end
