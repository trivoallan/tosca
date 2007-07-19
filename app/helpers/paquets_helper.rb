#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module PaquetsHelper
  # Il faut mettre un :include => [:arch,:conteneur] pour accélérer l'affichage
  def link_to_paquet(paquet)
    return '-' unless paquet and paquet.is_a? Paquet
    nom = "#{paquet.nom}-#{paquet.version}-#{paquet.release}"
    nom = "<i>#{nom}</i>" unless paquet.active
    link_to nom, paquet_path(paquet)
  end

  # call it like :
  # <%= link_to_new_contribution %>
  def link_to_new_paquet(logiciel_id = nil)
    link_to(image_create(_('un paquet')), new_paquet_path(logiciel_id), LinksHelper::NO_HOVER)
  end

end
