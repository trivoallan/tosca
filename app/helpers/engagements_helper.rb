#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module EngagementsHelper


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
      out << "#{link_to_actions_table e}"
      oldtypedemande = e.typedemande_id
     out 
    }
    result
  end
end
