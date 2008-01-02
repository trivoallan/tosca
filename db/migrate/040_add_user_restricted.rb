class AddUserRestricted < ActiveRecord::Migration
  def self.up
    add_column :users, :restricted, :boolean, :default => true
  end

  def self.down
    drop_column :users, :restricted
  end
end
