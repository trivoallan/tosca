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
module SoftwaresHelper

  # Display a link to a Software (software)
  # Options :
  #   * :size => size of the picture,
  #      (:small, :thumb & so on. See app/models/image.rb for full list)
  # Call it like this
  # public_link_to_software @software
  # public_link_to_software @software, :size => :thumb
  def public_link_to_software(software, options = {})
    return '-' unless software and software.is_a? Software
    public_link_to software.name, software_path(software), options
  end

  # Link to create a new url for a Software
  def link_to_new_urlsoftware(software_id)
    return '-' unless software_id
    options = new_urlsoftware_path(:software_id => software_id)
    link_to(image_create('an url'), options)
  end

  # Create a link to modify the active value in the form filter
  # Usage :
  #  <%= remote_link_to_software(:all) %> to display all the software
  def remote_link_to_software( param)
    ajax_call = PagesHelper::AJAX_OPTIONS.dup.update(:url => softwares_path)
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
