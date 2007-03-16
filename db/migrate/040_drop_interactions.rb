class DropInteractions < ActiveRecord::Migration
  def self.up
    drop_table :interactions
    
    remove_column :clients, :interactions_count
    remove_column :ingenieurs, :interactions_count
    remove_column :logiciels, :interactions_count
  end

  # no down. They weren't used anyway
  def self.down
  end
end
