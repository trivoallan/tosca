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
class AddBinaireId2request < ActiveRecord::Migration
  def self.up
    drop_table :demandes_paquets
    drop_table :binaires_demandes

    add_column :demandes, :binaire_id, :integer, :null => true, :default => nil
  end

  def self.down
    remove_column :demandes, :binaire_id, :integer, :null => true, :default => nil

    create_table "demandes_paquets", :id => false, :force => true do |t|
      t.column "paquet_id",  :integer, :default => 0, :null => false
      t.column "demande_id", :integer, :default => 0, :null => false
    end
    add_index "demandes_paquets", ["paquet_id"], :name => "demandes_paquets_paquet_id_index"
    add_index "demandes_paquets", ["demande_id"], :name => "demandes_paquets_demande_id_index"

    create_table "binaires_demandes", :id => false, :force => true do |t|
      t.column "binaire_id", :integer
      t.column "demande_id", :integer
    end
    add_index "binaires_demandes", ["binaire_id"], :name => "binaires_demandes_binaire_id_index"
    add_index "binaires_demandes", ["demande_id"], :name => "binaires_demandes_demande_id_index"

  end
end
