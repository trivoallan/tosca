class PrivateSoftware < ActiveRecord::Migration
  def self.up
    add_column :softwares, :private, :boolean, :default => false
  end

  def self.down
    remove_column :softwares, :private
  end
end
