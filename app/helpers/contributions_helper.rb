#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module ContributionsHelper

  # call it like : link_to_typedocument t 
  def link_to_contribution_logiciel(logiciel)
    return '-' unless logiciel 
    link_to logiciel.nom + ' (' + logiciel.contributions.size.to_s + ')', {
      :action => 'list', :id => logiciel.id }
  end


  # call it like : 
  # <%= link_to_new_contribution %>
  def link_to_new_contribution(logiciel_id = nil)
    link_to image_create('une contribution'), :controller => 
      'contributions', :action => 'new', :id => logiciel_id
  end

  # call it like : 
  # <%= link_to_contribution @contribution %>
  def link_to_contribution(c)
    return '-' unless c
    link_to c.nom, :controller => 'contributions', :action => 'show', :id => c
  end

  
  def link_to_all_contributions
    link_to 'Voir toutes les contributions', :action => 'list', :id => 'all'
  end

  # une contribution peut être liée à une demande externe
  # le "any" indique que la demande peut etre sur n'importe quel tracker
  def link_to_any_demande(contribution)
    return ' - ' if not contribution or not contribution.id_mantis 
    out = ''
    if contribution.id_mantis
      out << "<a href=\"http://www.08000linux.com/clients/minefi_SLL/mantis/view.php?id=#{contribution.id_mantis}\">
       Mantis ##{contribution.id_mantis}</a>"
    end
    out
  end

end
