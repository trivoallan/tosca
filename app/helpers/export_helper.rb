#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module ExportHelper
  # lien vers l'export de données
  # options :
  #  :data permet de spécifier un autre nom de controller (contexte par défaut)
  def link_to_export(options={})
    cname = ( options[:data] ? options[:data] : controller.controller_name)
    link_to "Exporter les #{cname}", :controller => 'export', :action => cname
  end


end

