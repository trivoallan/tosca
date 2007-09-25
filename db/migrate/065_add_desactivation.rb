class AddDesactivation < ActiveRecord::Migration
  def self.up
    add_column :identifiants, :desactive, :boolean, :default => false
  end

  def self.down
    remove_column :identifiants, :desactive
  end
end
