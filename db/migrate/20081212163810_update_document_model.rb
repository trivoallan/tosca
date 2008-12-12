class UpdateDocumentModel < ActiveRecord::Migration
  def self.up
    rename_column :documents, :title, :name
  end

  def self.down
    rename_column :documents, :name, :title
  end
end
