class RenameTypedocument2Documenttype < ActiveRecord::Migration
  def self.up
    rename_table :typedocuments, :documenttypes
    
    rename_column :document_versions, :typedocument_id, :documenttype_id
    rename_column :documents, :typedocument_id, :documenttype_id
  end

  def self.down
    rename_table :documenttypes, :typedocuments
    
    rename_column :document_versions, :documenttype_id, :typedocument_id
    rename_column :documents, :documenttype_id, :typedocument_id 
  end
end
