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
module ContractsHelper

  # Cette méthode nécessite un :include => [:client] pour
  # fonctionner correctement
  def link_to_contract(c)
    return '-' unless c
    link_to c.name, contract_path(c)
  end

  # call it like :
  # <%= link_to_new_contract(@client.id) %>
  def link_to_new_contract(client_id = nil)
    link_to(image_create(_('a contract')),
                     new_contract_path(:client_id => client_id))
  end

  def link_to_new_rule(rule)
    return '' unless rule
    options = self.send("new_#{rule.underscore.tr('/','_')}_path")
    link_to image_create(_(rule.humanize)), options
  end

  def link_to_rule(rule)
    return '' unless rule
    options = self.send("#{ActionController::RecordIdentifier.singular_class_name(rule)}_path", rule)
    link_to StaticImage::view, options
  end

  def link_to_edit_rule(rule)
    return '' unless rule
    options = self.send("edit_#{ActionController::RecordIdentifier.singular_class_name(rule)}_path", rule)
    link_to StaticImage::edit, options
  end


end
