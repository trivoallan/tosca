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
class DropMachineAndSocle < ActiveRecord::Migration
  def self.up
    remove_column :issues, :socle_id
    drop_table :machines
    drop_table :mainteneurs
    drop_table :socles
    drop_table :clients_socles
  end

  def self.down
    add_column :issues, :socle_id, :integer
    create_table "machines", :force => true do |t|
      t.integer "socle_id",    :default => 0, :null => false
      t.string  "acces"
      t.boolean "virtuelle"
      t.integer "hote_id"
      t.text    "description"
    end
    create_table "mainteneurs", :force => true do |t|
      t.string "name", :default => "", :null => false
    end

    create_table "socles", :force => true do |t|
      t.string  "name",           :default => "", :null => false
      t.integer "binaires_count"
    end
    create_table "clients_socles", :id => false, :force => true do |t|
      t.integer "client_id"
      t.integer "socle_id"
    end

    add_index "clients_socles", ["client_id"], :name => "index_clients_socles_on_client_id"
    add_index "clients_socles", ["socle_id"], :name => "index_clients_socles_on_socle_id"

  end
end
