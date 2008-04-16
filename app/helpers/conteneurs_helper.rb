#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module ConteneursHelper

  # call it like :
  # <%= link_to_new_conteneur %>
  def link_to_new_conteneur()
    link_to_no_hover image_create(_('a container')), new_conteneur_path
  end

end
