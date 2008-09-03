#
# Copyright (c) 2006-2008 Linagora
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
class LoadAdminAccount < ActiveRecord::Migration
  class Identifiant < ActiveRecord::Base
    has_one :ingenieur, :dependent => :destroy
  end
  class Ingenieur < ActiveRecord::Base; end

  def self.up
    # Do not erase existing accounts
    return unless Identifiant.count == 0

    admin_id, manager_id, expert_id, customer_id, viewer_id = 1,2,3,4,5
    # Id must be setted aside, unless it won't works as expected
    ### as of Rails 1.2.x
    user = Identifiant.new(:login => 'admin', :nom => 'Admin', :role_id =>
                           admin_id, :password =>
                           Digest::SHA1.hexdigest("linagora--#{'admin'}--"),
                           :informations => "")
    user.id = 1
    user.save!
    Ingenieur.create(:identifiant_id => 1)
  end

  def self.down
    admin = Identifiant.find_by_login('admin')
    admin.destroy if admin
  end
end
