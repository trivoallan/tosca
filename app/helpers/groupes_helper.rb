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
module GroupesHelper

  @@groupes = nil
  def public_link_to_groupes
    @@groupes ||= public_link_to(_('classification'), groupes_url)
  end

  # call it like :
  # <%= link_to_new_group %>
  def link_to_new_group()
    link_to image_create(_('a group')), new_groupe_path
  end


  # Lien vers la consultation d'UN groupe
  def link_to_groupe(groupe)
      link_to groupe.name, groupe_url(:id => groupe.id)
  end


end
