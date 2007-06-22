#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module BienvenueHelper

  def html_wrap(s, width=78)
    s.gsub!(/(.{1,#{width}})(\s+|\Z)/, "\\1<br />")
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
    elements.each { |d|
      result << "<tr class=\"demande_#{d.statut_id}\" " +
        " onclick=\"window.location.href='../demandes/comment/#{d.id}';\" >"
      result << yield(d)
      result << '</tr>'
    }
    result << '</table>'
  end

end

