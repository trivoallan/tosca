class AddIndexEmail < ActiveRecord::Migration
  def self.up
    add_index :identifiants, :email
  end

  def self.down
    remove_index :identifiants, :email
  end
end
