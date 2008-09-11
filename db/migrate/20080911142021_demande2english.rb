class Demande2english < ActiveRecord::Migration
  def self.up
    rename_table :demandes, :requests
    rename_table :typedemandes, :typerequests
    rename_column :requests, :typedemande_id, :typerequest_id
    rename_column :commitments, :typedemande_id, :typerequest_id
    rename_column :commentaires, :demande_id, :request_id
    rename_column :elapseds, :demande_id, :request_id
    rename_column :phonecalls, :demande_id, :request_id
  end

  def self.down
    rename_table :requests, :demandes
    rename_table :typerequests, :typedemandes
    rename_column :demandes, :typerequest_id, :typedemande_id
    rename_column :commitments, :typerequest_id, :typedemande_id
    rename_column :commentaires, :request_id, :demande_id
    rename_column :elapseds, :request_id, :demande_id
    rename_column :phonecalls, :request_id, :demande_id
  end
end
