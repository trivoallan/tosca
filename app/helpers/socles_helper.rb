#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module SoclesHelper

  # call it like : 
  # <%= link_to_socle @socle %>
  def link_to_socle(s)
    return "N/A" unless s
    link_to s.nom, :controller => 'socles', 
    :action => 'show', :id => s.id
  end

end
