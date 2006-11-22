class RenameRole < ActiveRecord::Migration
  def self.up
    rename_column :roles, :name, :nom
  end

  def self.down
    rename_column :roles, :nom, :name
  end
end
