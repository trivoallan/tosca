#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module ClientsHelper

  @@show_client = { :controller => 'clients', :action => 'show' }
  def link_to_client(c)
    return "N/A" unless c
    @@show_client[:id] = c
    link_to c.nom, @@show_client
  end

  # lien vers mon offre / mon client
  # options
  # :text texte du lien à afficher
  # :image image du client à afficher à la place
  def link_to_my_client(image = false)
    return nil unless @beneficiaire
    @@show_client[:id] = @beneficiaire.client_id
    label = image ? logo_client(@beneficiaire.client) : _('My&nbsp;Offer')
    link_to label, @@show_client
  end

end
