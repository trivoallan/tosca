#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module EngagementsHelper

  # MLO : Pas terrible ce helper, on remove ?
  # Call it : link_to_engagement('Voir','edit', engagement)
  def link_to_engagement(name, action, engagement)
    link_to name, :action => action, :id => engagement.id, :controller => 'engagements'
  end


  def link_to_new_engagement()
    link_to(image_create('engagement'), :action => 'new', 
            :controller => 'engagements')
  end

  # Display form for choosing engagements;
  # They MUST have been sort by the Engagement::ORDER options.
  # Call it like this :
  #   show_form_engagements(@contrat.engagements, @engagements, 'contrat[engagement_ids]' )
  # TODO : habiller et mettre des bordures pour que ca se distingue du reste
  #  cf /contrats/new pour le voir
  def show_form_engagements(object_engagement, engagements, nom)
    out = '<table>'
    out << '<tr><th>Demande</th><th>Sévérité</th><th></th>'
    out << '<th>Contournement</th><th>Correction</th></tr>'
    last_typedemande_id = 0
    last_severite_id = 0
    last_cycle = cycle('pair', 'impair')
    e = engagements.pop
    while (e) do
      out << '<tr><td colspan="5"><hr/></td></tr>' if e.typedemande_id != last_typedemande_id
      last_cycle = cycle('pair', 'impair') if e.severite_id != last_severite_id
      out << "<tr class=\"#{last_cycle}\">"
      out << '<td>'
      if e.typedemande_id != last_typedemande_id
        out << "<strong>#{e.typedemande.nom}</strong>" 
        last_typedemande_id = e.typedemande_id
      end
      out << '</td><td>'
      if e.severite_id != last_severite_id
        out << e.severite.nom 
        last_severite_id = e.severite_id
      end
      out << '</td><td>'
      out << "<input id=\"engagement_#{e.id}\" type=\"checkbox\" " 
      out << "name=\"#{nom}[]\" value=\"#{e.id}\" "
      out << 'checked="checked" ' if object_engagement.include? e
      out << '/>'
      out << "</td><td align=\"center\"><label for=\"engagement_#{e.id}\">"
      out << Lstm.time_in_french_words(e.contournement.days, true)
      out << '</label></td><td align="center">'
      out << Lstm.time_in_french_words(e.correction.days, true)
      out << '</td></tr>'
      e = engagements.pop
    end
    out << '</table'
  end

  def show_table_engagements(engagements)
    result = ''
    titres = ['Demande','Sévérité','Contournement','Correction']
    oldtypedemande = nil 
    result << show_table(engagements, Engagement, titres) { |e|
      out = ''
      out << (oldtypedemande == e.typedemande_id ? '<td></td>' : 
                "<td>#{e.typedemande.nom}</td>" )
      out << "<td>#{e.severite.nom}</td>"
      out << "<td>#{Lstm.time_in_french_words(e.contournement.days, true)}</td>"
      out << "<td>#{Lstm.time_in_french_words(e.correction.days, true)}</td>"
      if controller.controller_name == 'engagements'
        out << "#{link_to_actions_table e}"
      end
      oldtypedemande = e.typedemande_id
     out 
    }
    result
  end
end
