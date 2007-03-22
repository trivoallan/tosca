#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class AlterContributions < ActiveRecord::Migration
  def self.up
    add_column :contributions, :version, :string
    add_column :contributions, :synthese, :text
  end

  def self.down
    remove_column :contributions, :version
  end
end
