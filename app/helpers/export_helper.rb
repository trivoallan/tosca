#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module ExportHelper

  # créate a link with the images coresponding to the type mime of the export
  def export_images(url)
    style = {:class => 'nobackground'} 
    return link_to image_ods, url, style 
  end
  def requests_export_link
    export_link demandes_ods_export_url
  end
  def demandes_export_images
    export_images demandes_ods_export_url
  end
  def appels_export_images
    export_images appels_ods_export_url
  end
  def identifiants_export_images
    export_images identifiants_ods_export_url
  end
  def contributions_export_images
    export_images contributions_ods_export_url
  end
end

