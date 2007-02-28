#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module BienvenueHelper

  # Call it like :
  #   <%= show_liste_accueil(links, 'Groupe') %>
  def show_liste_accueil(elements, titre, options = {})
    elements.compact!
    size = elements.size
    return "" unless size > 0
    result = ''
    result << "<dt>#{titre.humanize}</dt>"
    result << ' <dd class="action">'
    # résumé des demandes
    result << show_table_demandes(@demandes, []) { |demande|
      "<td>#{link_to_demande demande, :show_id => true, :icon_severite => true}</td>"
    } if options[:demandes]
    result << '   <ul>'
    elements.each { |e| result << "<li>#{e}</li>" }
    result << '   </ul>'
    result << ' </dd>'
  end

  # Call it like :
  #   <% titres = ['Fichier', 'Taille', 'Auteur', 'Maj'] %>
  #   <%= show_table(@documents, Document, titres) {|e| "<td>#{e.nom}</td>"}%>
  def show_table_demandes(elements, titres)
    return "<br/><p>Aucune demande</p>" unless elements and elements.size > 0
    result = '<table>'
    if titres.size > 0
      result << '<tr>'
      titres.each {|t| result << "<th>#{t}</th>" }
      result << '</tr>'
    end
    elements.each_index { |i|
      infos = h(demande_description(elements[i]))
      result << "<tr class=\"demande_#{elements[i].statut_id}\" title=\"#{infos}\" " +
                " onclick=\"window.location.href='../demandes/comment/#{elements[i].id}';\" >"
      result << yield(elements[i])
      result << '</tr>'
    }
    result << '</table>'
  end

end

