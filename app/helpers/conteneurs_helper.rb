#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module ConteneursHelper

  # call it like :
  # <%= link_to_new_conteneur %>
  def link_to_new_conteneur()
    link_to(image_create(_('a container')), new_conteneur_path, 
            LinksHelper::NO_HOVER)
  end

end
