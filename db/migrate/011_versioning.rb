#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Versioning < ActiveRecord::Migration
  def self.up
    # create_versioned_table takes the same options hash
    # that create_table does
    Demande.create_versioned_table
    Document.create_versioned_table
  end

  def self.down
    Demande.drop_versioned_table
    Document.drop_versioned_table
  end
end
