#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module ExportHelper
  # lien vers l'export de données
  # options :
  #  :data permet de spécifier un autre nom de controller (contexte par défaut)
  def link_to_export(options={})
    cname = ( options[:data] ? options[:data] : controller.controller_name)
    link_to "Exporter les #{cname}", export_url(:action => cname)
  end

  def export_images(url)
    style = {:class => 'nobackground'} 
    return link_to image_ods, url, style 
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

