class LoadRoles < ActiveRecord::Migration
  class Role < ActiveRecord::Base; end

  def self.up
    # Permission distribution
    save_role = Proc.new do |role, id|
      role.id = id
      role.save
    end

    Role.destroy_all

    # Roles
    save_role.call(Role.new(:nom => 'admin', :info =>
                "One role to rule'em all"), 1)
    save_role.call(Role.new(:nom => 'manager', :info =>
                'One role for those who have the power and the knowledge'), 2)
    save_role.call(Role.new(:nom => 'expert', :info =>
                'One role for those who have the knowledge'), 3)
    save_role.call(Role.new(:nom => 'customer', :info =>
                "One role for the customer"), 4)
    save_role.call(Role.new(:nom => 'viewer', :info =>
                "One role with read-only customer"), 5)
    save_role.call(Role.new(:nom => 'public', :info =>
                "One role for the public access"), 6)

  end

  def self.down
    Role.destroy_all
  end
end
