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
class RenameTypedocument2Documenttype < ActiveRecord::Migration
  def self.up
    rename_table :typedocuments, :documenttypes
    
    rename_column :document_versions, :typedocument_id, :documenttype_id
    rename_column :documents, :typedocument_id, :documenttype_id
  end

  def self.down
    rename_table :documenttypes, :typedocuments
    
    rename_column :document_versions, :documenttype_id, :typedocument_id
    rename_column :documents, :documenttype_id, :typedocument_id 
  end
end
