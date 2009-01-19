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
module KnowledgesHelper

  # Call it like this :
  # <%= link_to_knowledge(@knowledge) %>
  def link_to_knowledge(k)
    return '-' unless k and k.is_a? Knowledge
    name = "#{k.level} - #{k.name}"
    res = link_to name, knowledge_path(k)
    res << " #{StaticPicture::subscription}" if k.subscribed?
    res
  end

  def link_to_new_knowledge
    return '' unless @session_user.engineer?
    options = new_knowledge_path
    link_to(image_create('a knowledge'), options)
  end

end
