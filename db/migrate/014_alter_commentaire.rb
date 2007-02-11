#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class AlterCommentaire < ActiveRecord::Migration
  def self.up
    change_column :commentaires, :prive,
    :boolean, :default => false, :null => false
  end

  def self.down
  end
end
