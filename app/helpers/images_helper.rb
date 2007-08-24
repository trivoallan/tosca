#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################

module ImagesHelper

  def image_create(message)
    desc = _("Post %s") % message
    image_tag("create_icon.png", StaticImage::options(desc, '16x16'))
  end

  private

  # por éviter la réaffection de desc à chaque coup
  def my_options(desc = '', size = nil )
    options = { :alt => desc, :title => desc, :class => 'no_hover' }
    options[:size] = size if size
    options
  end

  def logo_client(client)
    return '' if client.nil? or client.image.nil?
    image_tag(url_for_file_column(client.image, 'image', 'thumb'),
              image_options(client.nom))
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


end
