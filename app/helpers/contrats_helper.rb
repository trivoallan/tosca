#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module ContratsHelper

  # Cette méthode nécessite un :include => [:client] pour
  # fonctionner correctement
  def link_to_contrat(c)
    return '-' unless c
    link_to c.client.nom, contrat_path(c)
  end

  # call it like :
  # <%= link_to_new_contribution(@client.id) %>
  def link_to_new_contrat(client_id = nil)
    link_to image_create('un contrat'), new_contrat_path(:client_id => client_id)
  end

  # call it like :
  # <%= link_to_edit_contrat(c) %>
  def link_to_edit_contrat(c)
    return '-' unless c
    link_to image_edit, edit_contrat_path(c)
  end
end
