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
module ClientsHelper

  def link_to_client(c)
    return '-' unless c
    link_to c.name, client_path(c)
  end

  # lien vers mon offre / mon client
  # options
  # :text texte du lien à afficher
  # :image image du client à afficher à la place
  def link_to_my_client(image = false)
    return nil unless @recipient
    label = image ? logo_client(@recipient.client) : _('My&nbsp;Offer')
    link_to label, client_path(@recipient.client_id)
  end

  # Create a link to modify the active value in the form filter
  # Usage :
  #  <%= remote_link_to_clients(:all) %> to display all the software
  def remote_link_to_clients( param)
    ajax_call = PagesHelper::AJAX_OPTIONS.dup.update(:url => clients_path)
    if param == :actives
      text = _('Active clients')
      description = _('Display only active clients')
      value = 1
    else # :all
      text = _('Inactive clients')
      description = _('Display only inactive clients')
      value = -1
    end
    js_call = "document.forms['filters'].elements['filters[active]'].value=#{value};" <<
      remote_function(ajax_call)
    link_to_function(text, js_call, description)
  end

end
