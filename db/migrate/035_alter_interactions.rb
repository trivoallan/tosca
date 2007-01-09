class AlterInteractions < ActiveRecord::Migration
  def self.up
    add_column :interactions, :client_id, :integer
    add_index :interactions, :client_id
    add_column :clients, :interactions_count, :integer
  end

  def self.down
    remove_column :interactions, :client_id
    remove_column :clients, :interactions_count
  end
end
