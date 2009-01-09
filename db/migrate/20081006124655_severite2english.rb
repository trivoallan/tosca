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
class Severite2english < ActiveRecord::Migration
  def self.up
    rename_table :severites, :severities
    rename_column :comments, :severite_id, :severity_id
    rename_column :commitments, :severite_id, :severity_id
    rename_column :issues, :severite_id, :severity_id
  end

  def self.down
    rename_table :severities, :severites
    rename_column :comments, :severity_id, :severite_id
    rename_column :commitments, :severity_id, :severite_id
    rename_column :issues, :severity_id, :severite_id
  end
end
