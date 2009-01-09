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
class RenameTypecontribution2Contributiontype < ActiveRecord::Migration
  def self.up
    rename_table :typecontributions, :contributiontypes
    
    rename_column :contributions, :typecontribution_id, :contributiontype_id
  end

  def self.down
    rename_table :contributiontypes, :typecontributions
    
    rename_column :contributions, :contributiontype_id, :typecontribution_id
  end
end
