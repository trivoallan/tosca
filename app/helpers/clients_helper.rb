#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module ClientsHelper

  def link_to_client(c)
    return "N/A" unless c
    link_to c.nom, :controller => 'clients', 
    :action => 'show', :id => c
  end

  def logo_client(client)
    return '-' unless client
    image_tag(url_for_file_column(client.photo, 'image', 'thumb')) 
  end
end
