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
class CreateTeam < ActiveRecord::Migration
  def self.up
    create_table :teams do |t|
      t.string :name, :motto
      t.integer :user_cache, :contact_id
    end

    #This is a table for has_and_belongs_to_many
    create_table :contracts_teams, :id => false do |t|
      t.integer :contract_id, :team_id
    end
    add_index :contracts_teams, :contract_id
    add_index :contracts_teams, :team_id
    
    add_column :users, :team_id, :integer
    add_index :users, :team_id
    
    remove_column :ingenieurs, :expert_ossa
  end

  def self.down
    add_column :ingenieurs, :expert_ossa, :boolean, :default => false
    
    drop_table :teams
    drop_table :contracts_teams
    
    remove_index :users, :team_id
    remove_column :users, :team_id
  end
end
