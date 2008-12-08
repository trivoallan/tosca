class RenameTypecontribution2Contributiontype < ActiveRecord::Migration
  def self.up
    rename_table :typecontributions, :contributiontypes
    
    rename_column :contributions, :typecontribution_id, :contributiontype_id
  end

  def self.down
    rename_table :contributiontypes, :typecontributions
    
    rename_column :contributions, :contributiontype_id, :typecontribution_id
  end
end
