#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module UrlreversementsHelper

  def link_to_edit_urlreversement(u)
    return '-' unless u
    link_to image_edit, edit_urlreversement_path(u.id)
  end
end
