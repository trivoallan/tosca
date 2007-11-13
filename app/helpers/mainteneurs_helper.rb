#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module MainteneursHelper

  # call it like :
  # <%= link_to_new_mainteneur %>
  def link_to_new_mainteneur()
    link_to(image_create(_('a maintainer')), new_mainteneur_path, 
            LinksHelper::NO_HOVER)
  end

end
