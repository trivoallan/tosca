#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module LicensesHelper
    # call it like :
  # <%= link_to_new_license %>
  def link_to_new_license()
    link_to(image_create(_('a copyright')), new_license_path,
            LinksHelper::NO_HOVER)
  end

end
