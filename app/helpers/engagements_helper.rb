#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module EngagementsHelper

  # MLO : Pas terrible ce helper, on remove ?
  # Call it : link_to_engagement('Voir','edit', engagement)
  def link_to_engagement(name, action, engagement)
    link_to name, :action => action, :id => engagement.id, :controller => 'engagements'
  end

  # Display form for choosing engagements;
  # They MUST have been sort by the Engagement::ORDER options.
  def show_form_engagements(engagements)
    out = '<table>'
    out << '<tr><th>Demande</th><th>Sévérité</th>'
    out << '<th>Contournement</th><th>Correction</th></tr>'
    last_typedemande_id = 0
    last_severite_id = 0
    e = engagements.pop
    while (e) do
      out << '<td>'
      if e.typedemande_id != last_typedemande_id
        out << e.typedemande.nom 
        last_typedemande_id = e.typedemande_id
      end
      out << '</td><td>'
      if e.severite_id != last_severite_id
        out << e.severite.nom 
        last_severite_id = e.severite_id
      end
      out << '</td><td>'
      Lstm.time_in_french_words(e.contournement.days)
      out << '</td><td>'
      Lstm.time_in_french_words(e.correction.days)
      out << '</td>'
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
      out << "<td>#{display_jours e.contournement}</td>"
      out << "<td>#{display_jours e.correction}</td>"
      if controller.controller_name == 'engagements'
        out << "#{link_to_actions_table e}"
      end
      oldtypedemande = e.typedemande_id
     out 
    }
    result
  end
end
