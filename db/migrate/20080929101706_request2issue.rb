class Request2issue < ActiveRecord::Migration
  def self.up
    rename_table :requests, :issues
    rename_table :typerequests, :typeissues
    rename_column :issues, :typerequest_id, :typeissue_id
    rename_column :commitments, :typerequest_id, :typeissue_id
    rename_column :comments, :request_id, :issue_id
    rename_column :elapseds, :request_id, :issue_id
    rename_column :phonecalls, :request_id, :issue_id
  end

  def self.down
    rename_table :issues, :requests
    rename_table :typeissues, :typerequests
    rename_column :requests, :typeissue_id, :typerequest_id
    rename_column :commitments, :typeissue_id, :typerequest_id
    rename_column :comments, :issue_id, :request_id
    rename_column :elapseds, :issue_id, :request_id
    rename_column :phonecalls, :issue_id, :request_id
  end
end
