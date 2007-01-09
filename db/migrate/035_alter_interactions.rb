class AlterInteractions < ActiveRecord::Migration
  def self.up
    add_column :interactions, :client_id, :integer
    add_index :interactions, :client_id
  end

  def self.down
    remove_column :interactions, :client_id
  end
end
