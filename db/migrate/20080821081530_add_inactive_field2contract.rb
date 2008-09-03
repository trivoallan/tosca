class AddInactiveField2contract < ActiveRecord::Migration

  def self.up
    add_column :contracts, :inactive, :boolean, :default => false
  end

  def self.down
    remove_column :contracts, :inactive
  end

end
