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
class Identifiant2user < ActiveRecord::Migration
  COLUMNS = {
    :titre => :title,
    :nom => :name,
    :telephone => :phone
  }

  def self.up
    # Two errors of youth. they are rescued because only present on
    # some old prod databases ;).
    begin; drop_table(:users); rescue; end
    begin
      drop_table(:fournisseurs)
      remove_column :paquets, :fournisseur_id
    rescue; end

    rename_table(:identifiants, :users)
    COLUMNS.each { |key, value|
      rename_column(:users, key, value)
    }
    tables = [ :ingenieurs, :beneficiaires, :commentaires,
               :documents, :preferences ]
    tables.each do |t|
      # remove_index t, :identifiant_id
      rename_column t, :identifiant_id, :user_id
      # add_index t, :user_id
    end

    rename_column :document_versions, :identifiant_id, :user_id
  end

  def self.down
    rename_table(:users, :identifiants)
    COLUMNS.each { |key, value|
      rename_column(:identifiants, value, key)
    }
    rename_column :ingenieurs, :user_id, :identifiant_id
    rename_column :beneficiaires, :user_id, :identifiant_id
    rename_column :commentaires, :user_id, :identifiant_id
    rename_column :document_versions, :user_id, :identifiant_id
    rename_column :documents, :user_id, :identifiant_id
    rename_column :preferences, :user_id, :identifiant_id
  end
end
