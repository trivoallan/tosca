class AddDesactivation < ActiveRecord::Migration
  def self.up
    add_column :identifiants, :inactive, :boolean, :default => false
  end

  def self.down
    remove_column :identifiants, :inactive
  end
end
