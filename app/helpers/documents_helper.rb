#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module DocumentsHelper

  # call it like : link_to_typedocument t 
  def link_to_typedocument(typedocument)
    link_to typedocument.nom + ' (' + typedocument.documents.size.to_s + ')', {
      :action => 'list', :id => typedocument }
  end
end
