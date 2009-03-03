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
module ReleasesHelper

  def link_to_release(release)
    return '-' unless release and release.version
    link_to release.full_name, release_path(release.id)
  end

  # Link to create a new url for a release
  def link_to_new_release(version_id)
    return '-' if version_id.blank?
    options = new_release_path(:version_id => version_id)
    link_to image_create(_('release')), options
  end

end
