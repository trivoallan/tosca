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

module PicturesHelper

  #Create icon with a nice tooltip
  def image_create(message)
    desc = _("Add %s") % message
    image_tag("icons/add.png", StaticPicture::options(desc, '16x16'))
  end

  def image_next_page
    image_tag("icons/resultset_next.png", StaticPicture::options(_('Previous Page'), '16x16'))
  end
  def image_prev_page
    image_tag("icons/resultset_previous.png", StaticPicture::options(_('Next Page'), '16x16'))
  end

  #Disconnect icon with the tooltip
  def image_disconnect
    desc = _('Logout')
    image_tag('icons/disconnect.gif', StaticPicture::options(desc, '16x16'))
  end

  #Connect icon with the tooltip
  def image_connect
    desc = _('Log in')
    image_tag('icons/connect.png', StaticPicture::options(desc, '16x16'))
  end

  def image_star(desc)
    image_tag('icons/star.png', StaticPicture::options(desc, '16x16'))
  end

  def image_expand_all
    image_tag('icons/expand_all.png', StaticPicture::options(_('Expand all'), '16x16'))
  end

  def image_collapse_all
    image_tag('icons/collapse_all.png', StaticPicture::options(_('Collapse all'), '16x16'))
  end

  private

  # por éviter la réaffection de desc à chaque coup
  def my_options(desc = '', size = nil )
    options = { :alt => desc, :title => desc }
    options[:size] = size if size
    options
  end

  # Beware that the inactive thumb is only available for thumb size
  # Call like this :
  #  <%= logo_client(@client) %>
  #  <%= logo_client(@client, :small) %>
  def logo_client(client, size = :thumb)
    return '' if client.nil? or size.nil?
    return client.name if client.picture.blank?
    if size == :thumb
      size = (client.inactive? ? :inactive_thumb : :thumb)
    end
    image_tag(url_for_image_column(client.picture, 'image', size) || client.name,
              StaticPicture::options(client.name_clean))
  end

  # Display the software's logo, if possible
  # Possible options are those specified in image model.
  # Currently :small, :thumb, :medium, :inactive_thumb
  def software_logo(software, options = {})
    return '' if software.nil? or software.picture.blank?
    size = options[:size] || :small
    path = url_for_image_column(software.picture, 'image', size)
    return '' if path.blank?
    image_tag(path, :class => "aligned_picture",
              :alt => software.name, :title => software.name)
  end

  # See usage in reporting_helper#progress_bar
  # It show a percentage of progression.
  def image_percent(percent, color, desc)
    style = "background-position: #{percent}px; background-color: #{color};"
    options = { :alt => desc, :title => desc, :style => style,
      :class => 'percentImage aligned_picture' }
    image_tag('percentimage.png', options)
  end

  # call it like :
  # <%= link_to_new_version(@software) %>
  def link_to_new_client_logo
    link_to(image_create(_('a logo')), new_picture_path, :target => '_blank')
  end

end
