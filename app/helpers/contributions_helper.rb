#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module ContributionsHelper

  # this dump the pretty table of all contributions of the
  # software in parameters
  def public_table_of_contributions(contribs)
    return '' unless contribs.size > 0
    out = '<div class="bloc_scroll"><table class="show"><tr><th>Date</th><th>Version</th><th>Résumé</th></tr>'
    contribs.each{|c|
      out << "<td>#{c.reverse_le_formatted}</td>"
      out << "<td>#{c.version}</td>"
      out << "<td>#{public_link_to_contribution(c)}</td>"
    }
    out << '</table></div>'
  end

  # call it like : link_to_contribution_logiciel
  def public_link_to_contribution_logiciel(logiciel)
    return '-' unless logiciel 
    public_link_to logiciel.nom + ' (' + logiciel.contributions.size.to_s + ')', {
      :action => 'list', :id => logiciel.id }
  end

  @@contributions = nil
  def public_link_to_contributions
    @@contributions ||= public_link_to(_('contributions'), :controller => 'contributions', :action => 'list')
  end

  # call it like : 
  # <%= link_to_new_contribution %>
  def link_to_new_contribution(logiciel_id = nil)
    options = { :controller => 'contributions', :action => 'new', :id => logiciel_id }
    link_to(image_create(_('une contribution')), options, LinksHelper::NO_HOVER)
  end

  # call it like : 
  # <%= link_to_contribution @contribution %>
  def link_to_contribution(c)
    return '-' unless c
    link_to c.nom, :controller => 'contributions', :action => 'show', :id => c
  end

  def public_link_to_contribution(c)
    return '-' unless c
    public_link_to(c.nom, :controller => 'contributions', 
                   :action => 'show', :id => c)
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
