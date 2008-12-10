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
module ContributionurlsHelper

  def link_to_edit_contributionurl(u)
    return '-' unless u
    link_to StaticImage::edit, edit_contributionurl_path(u.id)
  end

  def link_to_new_contributionurl(contribution_id)
    path = new_contributionurl_path(:contribution_id => contribution_id)
    link_to image_create(_('new url')), path
  end

end
