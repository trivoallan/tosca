#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module PaquetsHelper
  # Il faut mettre un :include => [:arch,:conteneur] pour accélérer l'affichage
  def link_to_paquet(paquet)
    return "N/A" unless paquet
    nom = "#{paquet.nom}-#{paquet.version}-#{paquet.release}"
    link_to nom, :controller => 'paquets', 
    :action => 'show', :id => paquet
  end

  # call it like : 
  # <%= link_to_new_contribution %>
  def link_to_new_paquet(logiciel_id = nil)
    options = { :controller => 'paquets', :action => 'new', :id => logiciel_id }
    link_to(image_create(_('un paquet')), options, ImagesHelper::NO_HOVER)
  end

end
