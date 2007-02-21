#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class AlterMachines < ActiveRecord::Migration
  def self.up
    add_column :machines, :acces, :string
    add_column :machines, :virtuelle, :boolean
    add_column :machines, :hote_id, :integer, :null => true # machine_id
    add_column :machines, :description, :text

    add_column :socles, :client_id, :integer
    add_index :socles, :client_id

    remove_column :machines, :nom
  end

  def self.down
    remove_column :machines, :acces
    remove_column :machines, :virtuelle
    remove_column :machines, :hote_id
    remove_column :machines, :description

    # remove_column efface l'index
    remove_column :socles, :client_id
   
    add_column :machines, :nom, :string
  end
end
