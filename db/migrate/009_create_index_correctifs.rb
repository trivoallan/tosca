#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class CreateIndexCorrectifs < ActiveRecord::Migration
  def self.up
    add_index :correctifs_demandes, :correctif_id
    add_index :correctifs_demandes, :demande_id
    add_index :correctifs_paquets, :paquet_id
    add_index :correctifs_paquets, :correctif_id
    add_index :correctifs, :logiciel_id
  end

  def self.down
    remove_index :correctifs_demandes, :correctif_id
    remove_index :correctifs_demandes, :demande_id
    remove_index :correctifs_paquets, :paquet_id
    remove_index :correctifs_paquets, :correctif_id
    remove_index :correctifs, :logiciel_id
  end
end
