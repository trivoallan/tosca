
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
    return '' if client.nil? or size.nil?
    return client.name if client.image.blank?
    if size == :thumb
      size = (client.inactive? ? :inactive_thumb : :thumb)
    end
    image_tag(url_for_image_column(client.image, 'image', size) || client.name,
              image_options(client.name_clean))
  end

  # Display the software's logo, if possible
  # Possible options are those specified in image model.
  # Currently :small, :thumb, :medium, :inactive_thumb
  def software_logo(software, options = {})
    return '' if software.nil? or software.image.blank?
    size = options[:size] || :small
    path = url_for_image_column(software.image, 'image', size)
    return '' if path.blank?
    image_tag(path, :class => "aligned_picture",
              :alt => software.name, :title => software.name)
  end

  #TODO Merger avec StaticImage
  def image_options(desc = '', size = nil )
    options = { :alt => desc, :title => desc, :class => 'no_hover' }
    options[:size] = size if size
    options
  end

  # See usage in reporting_helper#progress_bar
  # It show a percentage of progression.
  def image_percent(percent, color, desc)
    style = "background-position: #{percent}px; background-color: #{color};"
    options = { :alt => desc, :title => desc, :style => style,
      :class => 'percentImage no_hover aligned_picture' }
    image_tag('percentimage.png', options)
  end

  # call it like :
  # <%= link_to_new_version(@logiciel) %>
  def link_to_new_client_logo()
    options = LinksHelper::NO_HOVER.dup.update(:target => '_blank')
    link_to(image_create(_('a logo')), new_img_path, options)
  end


end
