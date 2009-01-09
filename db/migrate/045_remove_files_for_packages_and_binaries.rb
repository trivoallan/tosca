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
class RemoveFilesForPackagesAndBinaries < ActiveRecord::Migration
  def self.up
    drop_table :fichierbinaires
    drop_table :fichiers

    remove_column :binaires, :fichierbinaires_count
    remove_column :paquets, :fichiers_count
  end

  def self.down
    create_table "fichiers", :force => true do |t|
      t.column "paquet_id", :integer, :default => 0,  :null => false
      t.column "chemin",    :string,  :default => ""
      t.column "taille",    :integer, :default => 0,  :null => false
    end
    add_index "fichiers", ["paquet_id"]

    create_table "fichierbinaires", :force => true do |t|
      t.column "binaire_id", :integer
      t.column "chemin",     :string
      t.column "taille",     :integer
    end
    add_index "fichierbinaires", ["binaire_id"]

    add_column :binaires, :fichierbinaires_count, :integer
    add_column :paquets, :fichiers_count, :integer
  end
end
