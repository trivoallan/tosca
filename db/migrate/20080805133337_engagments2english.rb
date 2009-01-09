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
class Engagments2english < ActiveRecord::Migration
  def self.up
    rename_table :contracts_engagements, :commitments_contracts
    rename_column :commitments_contracts, :engagement_id, :commitment_id
    add_index :commitments_contracts, :commitment_id

    rename_table :engagements, :commitments
    add_index :commitments, ["severite_id", "typedemande_id"], :name => "commitments_severite_id_index"
  end

  def self.down
    rename_table :contracts_commitments, :contracts_engagements
    rename_column :contracts_engagements, :commitment_id, :engagement_id
    add_index :contracts_engagements, :engagement_id

    rename_table :commitments, :engagements
    add_index :engagements, ["severite_id", "typedemande_id"], :name => "engagements_severite_id_index"
  end
end
