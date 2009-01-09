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
class AddCreatedBy < ActiveRecord::Migration
  class Client < ActiveRecord::Base; end
  class Contract < ActiveRecord::Base; end

  def self.up
    add_column :clients, :creator_id, :integer, :null => false, :default => 1
    add_column :contracts, :creator_id, :integer, :null => false, :default => 1
    Client.update_all("creator_id = 1")
    Contract.update_all("creator_id = 1")
  end

  def self.down
    remove_column :clients, :created_by
    remove_column :contracts, :created_by
  end
end
