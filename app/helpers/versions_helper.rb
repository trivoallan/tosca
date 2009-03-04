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
module VersionsHelper

  def link_to_version(version)
    return '-' unless version and version.is_a? Version
    name = "<i>#{version}</i>"
    link_to(name, version_path(version)) || name
  end

  # call it like :
  # <%= link_to_new_version(@software) %>
  def link_to_new_version(software = nil)
    return '' unless software
    path = new_version_path(:software_id => software.id)
    link_to(image_create(_('a package')), path)
  end

end
