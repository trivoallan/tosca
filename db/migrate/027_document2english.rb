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
class Document2english < ActiveRecord::Migration
  FICHIER = File.expand_path(RAILS_ROOT) + "/files/document/fichier/"
  FILE = File.expand_path(RAILS_ROOT) + "/files/document/file/"
  def self.up
    rename_column :documents, :titre, :title
    rename_column :documents, :fichier, :file

    rename_column :document_versions, :titre, :title
    rename_column :document_versions, :fichier, :file


    File.rename(FICHIER, FILE) if File.exist? FICHIER and !File.exist? FILE
  end

  def self.down
    rename_column :documents, :title, :titre
    rename_column :documents, :file, :fichier

    rename_column :document_versions, :title, :titre
    rename_column :document_versions, :file, :fichier

    File.rename(FILE, FICHIER) if File.exist? FILE and !File.exist? FICHIER
  end
end
