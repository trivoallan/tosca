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
class Picture < ActiveRecord::Base
  has_one :software
  has_one :client

  validates_presence_of :image

  # TODO : rename this column into 'file', with the appropriate migration
  # /!\ do not forget to move Directory during this migration /!\
  file_column :image, :fix_file_extensions => nil, :magick => {
    :versions => {
      :small => { :size => "75x25" },
      :thumb => { :size => "150x50" },
      :medium => { :size => "640x480" },
      :inactive_thumb => { :size => "150x50",
        :transformation => Proc.new { |image|
          image.view(0, 0, image.columns, image.rows) do |view|
            center = image.rows/2
            view[[center-1, center, center+1]][] = 'black'
          end
          image
        }
      }
    }
  }, :root_path => File.join(RAILS_ROOT, "public")

  def name
    return _("Logo '%s'") % software.name if software
    return _("Logo '%s'") % client.name if client
    description
  end
end
