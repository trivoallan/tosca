class RenameTypeissue2Issuetype < ActiveRecord::Migration
  def self.up
    rename_table :typeissues, :issuetypes
    
    rename_column :commitments, :typeissue_id, :issuetypes_id
    rename_column :issues, :typeissue_id, :issuetypes_id
  end

  def self.down
    rename_table :issuetypes, :typeissues
    
    rename_column :commitments, :issuetypes_id, :typeissue_id
    rename_column :issues, :issuetypes_id, :typeissue_id
  end
end
