#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class AlterLicencesAndPaquets < ActiveRecord::Migration
  # Un peu de nettoyage dans le modèle.
  # On passe la compatibilité des licenses en booléen
  def self.up
    remove_column :paquets, :incoherences
    remove_column :licenses, :compatible_oss
    add_column :licenses, :certifie_osi, :boolean
  end

  def self.down
    add_column :paquets, :incoherences, :string
    add_column :licenses, :compatible_oss, :string
    remove_column :licenses, :certifie_osi
  end
end
