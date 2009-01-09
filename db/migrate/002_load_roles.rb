#
# Copyright (c) 2006-2009 Linagora
#
# This file is part of Tosca
#
# Tosca is free software, you can redistribute it and/or modify
# it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
# Tosca is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
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
