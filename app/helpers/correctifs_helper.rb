#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module CorrectifsHelper
  # call it like : 
  # <%= link_to_correctif @correctif %>
  def link_to_correctif(c)
    return "N/A" unless c
    link_to c.nom, :controller => 'correctifs', 
    :action => 'show', :id => c.id
  end
end
