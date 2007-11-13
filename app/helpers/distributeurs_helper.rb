#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module DistributeursHelper
  # call it like :
  # <%= link_to_new_distributeur %>
  def link_to_new_distributeur()
    link_to(image_create(_('a distributor')), new_distributeur_path, 
            LinksHelper::NO_HOVER)
  end

end
