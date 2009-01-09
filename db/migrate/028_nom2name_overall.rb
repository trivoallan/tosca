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
class Nom2nameOverall < ActiveRecord::Migration
  TABLES = %w(arches binaires clients communautes competences
              conteneurs contracts contributions dependances
              distributeurs etatreversements groupes
              licenses logiciels mainteneurs paquets roles severites statuts
              socles supports typecontributions typedemandes
              typedocuments typeurls)

  def self.up
    # needed 4 sqlite ... :/
    # remove_index "paquets", ["nom", "version", "release"]
    TABLES.each{|t| rename_column t, :nom, :name }
    # add_index "paquets", ["name", "version", "release"]

    drop_table 'etapes'
  end

  def self.down
    TABLES.each{|t| rename_column t, :name, :nom }
    create_table "etapes", :force => true do |t|
      t.column "nom",         :string, :default => "", :null => false
      t.column "description", :text
    end
  end
end
