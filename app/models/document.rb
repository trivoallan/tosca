#
# Copyright (c) 2006-2008 Linagora
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
class Document < ActiveRecord::Base
  belongs_to :client
  belongs_to :typedocument
  belongs_to :user
  file_column :file, :fix_file_extensions => nil


  #versioning, qui s'occupe de la table documents_versions
  acts_as_versioned
  validates_length_of :title, :within => 3..60
  validates_presence_of :title, :file, :user, :client, :typedocument

  def self.set_scope(client_ids)
    self.scoped_methods << { :find => { :conditions =>
        [ 'documents.client_id IN (?)', client_ids ] } }
  end

  def date_delivery_on_formatted
    display_time read_attribute(:date_delivery)
  end

  def to_param
    "#{id}-#{title.gsub(/[^a-z1-9]+/i, '-')}"
  end

  def name
    title
  end

  def self.content_columns
    @content_columns ||= columns.reject { |c| c.primary ||
        c.name =~ /(_id|_on|date_delivery|fichier)$/ || c.name == inheritance_column }
  end

end
