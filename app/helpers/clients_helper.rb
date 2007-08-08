#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module ClientsHelper

  def link_to_client(c)
    return "N/A" unless c
    link_to c.nom, client_path(c)
  end

  # lien vers mon offre / mon client
  # options
  # :text texte du lien à afficher
  # :image image du client à afficher à la place
  def link_to_my_client(image = false)
    return nil unless @beneficiaire
    label = image ? StaticImage::client(@beneficiaire.client) : _('My&nbsp;Offer')
    link_to label, client_path(@beneficiaire.client_id)
  end

end
