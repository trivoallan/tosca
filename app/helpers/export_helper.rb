#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module ExportHelper

  def requests_export_link
    export_link demandes_ods_export_url
  end
  def demandes_export_link
    export_link demandes_ods_export_url
  end
  def appels_export_images
    export_link appels_ods_export_url
  end
  def identifiants_export_images
    export_link identifiants_ods_export_url
  end
  def comex_export_link
    export_link comex_ods_export_url
  end
  def contributions_export_link
    export_link contributions_ods_export_url
  end


  private
  # create a link with the images coresponding to the type mime of the export
  def export_link(url)
    style = {:class => 'nobackground'}
    link_to(_('Export in %s') % image_ods, url)
  end
end

