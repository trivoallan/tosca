#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module ClientsHelper

  #Call it : link_to_engagement('Voir','edit', engagement)
  def link_to_engagement(name, action, engagement)
    link_to name, :action => action, :id => engagement.id, :controller => 'engagements'
  end


  def link_to_client(c)
    return "N/A" unless c
    link_to c.nom, :controller => 'clients', 
    :action => 'show', :id => c
  end
end
