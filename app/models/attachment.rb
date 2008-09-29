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
class Attachment < ActiveRecord::Base
  file_column :file, :fix_file_extensions => nil,
    :magick => {
      :versions => {
        :fit_size => { :size => "800x600>" }
      }
    }

  has_one :comment

  validates_presence_of :file, :comment

  def name
    return file[/[._ \-a-zA-Z0-9]*$/]
  end

  # special scope : only used for file downloads
  # see FilesController
  def self.set_scope(client_id)
    joins = ''
    joins << 'LEFT OUTER JOIN comments ON comments.attachment_id = attachments.id '
    joins << 'LEFT OUTER JOIN issues ON issues.id = comments.issue_id '
    joins << 'LEFT OUTER JOIN recipients ON recipients.id = issues.recipient_id '
    self.scoped_methods << { :find => {
       :conditions => [ 'recipients.client_id = ?', client_id ],
       :joins => joins }
    }
  end

end
