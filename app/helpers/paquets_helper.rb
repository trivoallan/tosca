#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module PaquetsHelper
  # Il faut mettre un :include => [:arch,:conteneur] pour accélérer l'affichage
  def link_to_paquet(paquet)
    return '-' unless paquet and paquet.is_a? Paquet
    name = paquet.to_s
    name = "<i>#{name}</i>" unless paquet.active
    link_to name, paquet_path(paquet)
  end

  # call it like :
  # <%= link_to_new_paquet(@logiciel) %>
  def link_to_new_paquet(logiciel = nil)
    return '' unless logiciel
    path = new_paquet_path(:logiciel_id => logiciel.id,:referent => logiciel.referent)
    link_to(image_create(_('a package')), path, LinksHelper::NO_HOVER)
  end

end
