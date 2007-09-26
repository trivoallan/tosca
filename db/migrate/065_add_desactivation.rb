class AddDesactivation < ActiveRecord::Migration
  def self.up
    add_column :identifiants, :inactive, :boolean, :default => false, :null => false
    change_column :identifiants, :login, :string, :limit => 20, :null => false
    change_column :identifiants, :password, :string, :limit => 60, :null => false
  end

  def self.down
    remove_column :identifiants, :inactive
  end
end
