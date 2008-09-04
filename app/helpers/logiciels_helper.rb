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
module LogicielsHelper

  # Display a link to a Logiciel (software)
  # Options :
  #   * :size => size of the picture,
  #      (:small, :thumb & so on. See app/models/image.rb for full list)
  # Call it like this
  # public_link_to_logiciel @logiciel
  # public_link_to_logiciel @logiciel, :size => :thumb
  def public_link_to_logiciel(logiciel, options = {})
    return '-' unless logiciel and logiciel.is_a? Logiciel
    public_link_to logiciel.name, logiciel_path(logiciel), options
  end

  # Link to create a new url for a Logiciel
  def link_to_new_urllogiciel(logiciel_id)
    return '-' unless logiciel_id
    options = new_urllogiciel_path(:logiciel_id => logiciel_id)
    link_to(image_create('an url'), options, LinksHelper::NO_HOVER)
  end

  # Create a link to modify the active value in the form filter
  # Usage :
  #  <%= remote_link_to_software(:all) %> to display all the software
  def remote_link_to_software( param)
    ajax_call = PagesHelper::AJAX_OPTIONS.dup.update(:url => logiciels_path)
    if param == :supported
      text = _('My supported software')
      description = _('Display only software supported by your contract')
      value = 1
    else
      text = _('All software')
      description = _('Display all software')
      value = 0
    end
    js_call = "document.forms['filters'].active.value=#{value};" <<
      remote_function(ajax_call)
    link_to_function(text, js_call, description)
  end

end
