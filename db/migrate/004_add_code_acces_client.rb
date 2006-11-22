#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class AddCodeAccesClient < ActiveRecord::Migration
  def self.up
    add_column :clients, :code_acces, :string, :null => false
  end

  def self.down
    remove_column :clients, :code_acces
  end
end
