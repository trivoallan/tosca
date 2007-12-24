class LoadRoles < ActiveRecord::Migration
  class Role < ActiveRecord::Base; end

  def self.up
    # Roles
    Role.create(:nom => 'admin', :info => "One role to rule'em all")
    Role.create(:nom => 'manager', :info =>
                'One role for those who have the power and the knowledge')
    Role.create(:nom => 'expert', :info =>
                'One role for those who have the knowledge')
    Role.create(:nom => 'customer', :info => "One role for the customer")
    Role.create(:nom => 'viewer', :info => "One role with read-only customer")

  end

  def self.down
    Role.find(:all).each{|r| r.destroy }
  end
end
