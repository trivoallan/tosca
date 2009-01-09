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
class Request2issue < ActiveRecord::Migration
  def self.up
    rename_table :requests, :issues
    rename_table :typerequests, :typeissues
    rename_column :issues, :typerequest_id, :typeissue_id
    rename_column :commitments, :typerequest_id, :typeissue_id
    rename_column :comments, :request_id, :issue_id
    rename_column :elapseds, :request_id, :issue_id
    rename_column :phonecalls, :request_id, :issue_id
  end

  def self.down
    rename_table :issues, :requests
    rename_table :typeissues, :typerequests
    rename_column :requests, :typeissue_id, :typerequest_id
    rename_column :commitments, :typeissue_id, :typerequest_id
    rename_column :comments, :issue_id, :request_id
    rename_column :elapseds, :issue_id, :request_id
    rename_column :phonecalls, :issue_id, :request_id
  end
end
