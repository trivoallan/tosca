#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class CreateCommunautes < ActiveRecord::Migration
  def self.up
    create_table :communautes do |t|
      t.column :nom, :string, :null => false
      t.column :description, :text, :null => false
      t.column :url, :string, :null => false
      t.column :created_on, :timestamp, :null => false
      t.column :updated_on, :timestamp, :null => false
    end

  end

  def self.down
    drop_table :communautes
  end
end
