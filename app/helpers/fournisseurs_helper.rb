#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module FournisseursHelper

  # call it like :
  # <%= link_to_new_fournisseur %>
  def link_to_new_fournisseur()
    link_to(image_create(_('a provider')), new_fournisseur_path, 
            LinksHelper::NO_HOVER)
  end

end
