
#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################

module ImagesHelper

  def image_create(message)
    desc = _("Add %s") % message
    image_tag("create_icon.png", StaticImage::options(desc, '16x16'))
  end

  private

  # por éviter la réaffection de desc à chaque coup
  def my_options(desc = '', size = nil )
    options = { :alt => desc, :title => desc, :class => 'no_hover' }
    options[:size] = size if size
    options
  end

  # Beware that the inactive thumb is only available for thumb size
  #Call like this :
  #  <%= logo_client(@client) %>
  #  <%= logo_client(@client, :small) %>
  def logo_client(client, size = :thumb)
    return '' if client.nil? or client.image.blank? or size.nil?
    if size == :thumb
      size = (client.inactive? ? :inactive_thumb : :thumb)
    end
    image_tag(url_for_image_column(client.image, 'image', size) || client.name,
              image_options(client.name_clean))
  end

  def software_logo(software, options = {})
    return '' if software.nil? or software.image.blank?
    image_tag(url_for_image_column(software.image, 'image',
                                   options[:size] || :small) || software.name)
  end

  #TODO Merger avec StaticImage
  def image_options(desc = '', size = nil )
    options = { :alt => desc, :title => desc, :class => 'no_hover' }
    options[:size] = size if size
    options
  end

  # See usage in reporting_helper#progress_bar
  # It show a percentage of progression.
  def image_percent(percent, color)
    desc = _('progress bar')
    style = "background-position: #{percent}px; background-color: #{color};"
    options = { :alt => desc, :title => desc, :style => style,
      :class => 'percentImage' }
    image_tag('percentimage.png', options)
  end

  # call it like :
  # <%= link_to_new_paquet(@logiciel) %>
  def link_to_new_client_logo()
    options = LinksHelper::NO_HOVER.dup.update(:target => '_blank')
    link_to(image_create(_('a logo')), new_img_path, options)
  end


end
