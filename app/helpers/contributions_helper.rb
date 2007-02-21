#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module ContributionHelper
  # call it like : 
  # <%= link_to_contribution @contribution %>
  def link_to_contribution(c)
    return "N/A" unless c
    link_to c.nom, :controller => 'contributions', 
    :action => 'show', :id => c.id
  end
end
