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
class CreateExtensionMeta < ActiveRecord::Migration
  def self.up
   create_table 'extension_meta', :force => true do |t|
      t.column 'name', :string
      t.column 'schema_version', :integer, :default => 0
      t.column 'enabled', :boolean, :default => true
    end
  end

  def self.down
    drop_table 'extension_meta'
  end
end
