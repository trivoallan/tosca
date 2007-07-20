#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module ExportHelper

  def requests_export_link
    export_link formatted_requests_export_path(:ods)
  end

  def appels_export_images
    export_link formatted_appels_export_path(:ods)
  end
  def identifiants_export_link
    export_link formatted_identifiants_export_path(:ods)
  end
  def comex_export_link
    export_link formatted_comex_export_path(:ods)
  end
  def contributions_export_link
    export_link formatted_contributions_export_path(:ods)
  end


  private
  # create a link with the images coresponding to the type mime of the export
  def export_link(url)
    style = {:class => 'nobackground'}
    link_to(_('Export in %s') % image_ods, url)
  end
end

