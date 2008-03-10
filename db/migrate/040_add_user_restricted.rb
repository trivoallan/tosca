class AddUserRestricted < ActiveRecord::Migration

  class User < ActiveRecord::Base
  end

  def self.up
    add_column :users, :restricted, :boolean, :default => true
    User.find(:all).each { |u|
      u.update_attribute(:restricted, false) if u.role_id = 1 # Admin
    }
  end

  def self.down
    remove_column :users, :restricted
  end
end
