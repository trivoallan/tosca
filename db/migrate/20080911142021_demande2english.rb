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
class Demande2english < ActiveRecord::Migration
  def self.up
    rename_table :demandes, :requests
    rename_table :typedemandes, :typerequests
    rename_column :requests, :typedemande_id, :typerequest_id
    rename_column :commitments, :typedemande_id, :typerequest_id
    rename_column :commentaires, :demande_id, :request_id
    rename_column :elapseds, :demande_id, :request_id
    rename_column :phonecalls, :demande_id, :request_id
  end

  def self.down
    rename_table :requests, :demandes
    rename_table :typerequests, :typedemandes
    rename_column :demandes, :typerequest_id, :typedemande_id
    rename_column :commitments, :typerequest_id, :typedemande_id
    rename_column :commentaires, :request_id, :demande_id
    rename_column :elapseds, :request_id, :demande_id
    rename_column :phonecalls, :request_id, :demande_id
  end
end
