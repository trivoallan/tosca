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
module ArchivesHelper
  
  def link_to_archive(archive)
    return '-' unless archive and archive.name
    link_to archive.name, archive_path(archive.id)
  end

  # Link to create a new url for a archive
  def link_to_new_archive(release_id)
    return '-' if release_id.blank?
    options = new_archive_path(:release_id => release_id)
    link_to image_create(_('archive')), options
  end
  
end
