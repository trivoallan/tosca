class DropDocuments < ActiveRecord::Migration
  def self.up
    require 'fileutils'

    drop_table :documents
    drop_table :document_versions
    drop_table :documenttypes
    FileUtils.rm_rf "#{RAILS_ROOT}/files/document"
  end

  def self.down
    throw ActiveRecord::IrreversibleMigration
  end
end
