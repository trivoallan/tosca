class UpdateDocumentModel < ActiveRecord::Migration
  def self.up
    rename_column :documents, :title, :name
    rename_column :document_versions, :title, :name
  end

  def self.down
    rename_column :documents, :name, :title
    rename_column :document_versions, :name, :title
  end
end
