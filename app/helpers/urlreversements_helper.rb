#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module UrlreversementsHelper

  def link_to_edit_urlreversement(u)
    return '-' unless u
    link_to StaticImage::edit, edit_urlreversement_path(u.id)
  end

  def link_to_new_urlreversement(contribution_id)
    path = new_urlreversement_path(:contribution_id => contribution_id)
    link_to_no_hover image_create(_('new url')), path
  end

end
