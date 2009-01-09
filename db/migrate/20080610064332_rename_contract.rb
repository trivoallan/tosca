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
=begin

/!\ THIS MIGRATION IS ONLY FOR THE 08000LINUX /!\

=end

class RenameContract < ActiveRecord::Migration
  def self.up
#    rename_table :contrats, :contracts
#    
#    rename_table :contrats_engagements, :contracts_engagements
#    rename_column :contracts_engagements, :contrat_id, :contract_id
#    add_index :contracts_engagements, :contract_id
#    
#    rename_table :contrats_teams, :contracts_teams
#    rename_column :contracts_teams, :contrat_id, :contract_id
#    add_index :contracts_teams, :contract_id
    
#    rename_table :contrats_users, :contracts_users
#    rename_column :contracts_users, :contrat_id, :contract_id
#    add_index :contracts_users, :contract_id
#    
#    rename_column :demandes, :contrat_id, :contract_id
#    add_index :demandes, :contract_id
#    
#    rename_column :paquets, :contrat_id, :contract_id
#    add_index :paquets, :contract_id
#    
#    rename_column :phonecalls, :contrat_id, :contract_id
#    add_index :phonecalls, :contract_id
    
  end

  def self.down
#    rename_table :contracts, :contrats
#    
#    rename_table :contracts_engagements, :contrats_engagements
#    rename_column :contrats_engagements, :contract_id, :contrat_id
#    add_index :contrats_engagements, :contrat_id
#    
#    rename_table :contracts_teams, :contrats_teams
#    rename_column :contrats_teams, :contract_id, :contrat_id
#    add_index :contrats_teams, :contrat_id
#    
#    rename_table :contracts_users, :contrats_users
#    rename_column :contrats_users, :contract_id, :contrat_id
#    add_index :contrats_users, :contrat_id
#    
#    rename_column :demandes, :contract_id, :contrat_id
#    add_index :demandes, :contrat_id
#    
#    rename_column :paquets, :contract_id, :contrat_id
#    add_index :paquets, :contrat_id
#    
#    rename_column :phonecalls, :contract_id, :contrat_id
#    add_index :phonecalls, :contrat_id
  end
end
