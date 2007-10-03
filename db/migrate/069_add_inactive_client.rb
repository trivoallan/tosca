class AddInactiveClient < ActiveRecord::Migration
  def self.up
    add_column :clients, :inactive, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :clients, :inactive
  end
end
