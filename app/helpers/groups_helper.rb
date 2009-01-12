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
module GroupsHelper

  @@groups = nil
  def public_link_to_groups
    @@groups ||= public_link_to(_('classification'), groups_url)
  end

  # call it like :
  # <%= link_to_new_group %>
  def link_to_new_group
    link_to image_create(_('a group')), new_group_path
  end

  # Lien vers la consultation d'UN groupe
  def link_to_group(group)
      link_to group.name, group_url(:id => group.id)
  end

end
