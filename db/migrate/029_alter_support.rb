#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class AlterSupport < ActiveRecord::Migration
  def self.up
    change_column :supports, :maintenance, :boolean
    change_column :supports, :veille_technologique, :boolean
    change_column :supports, :assistance_tel, :boolean
    add_column :supports, :newsletter, :boolean
  end

  def self.down
    remove_column :supports, :newsletter
    # Les 3 autres colonnes étaient des enum('OUI','NON')
    # Une erreur de jeunesse :)
  end
end
