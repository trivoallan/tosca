#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module AccountHelper

  # Titles doit contenir un tableau
  # Champs doit contenir un tableau
  # Les éléments de Titles et Champs doivent être affichable par to_s
  # options 
  # :title => Donne un titre au tableau
  # :subtitle => Donne un sous titre au tableau
  # Ex : show_table_form( { "TOTO", "TITI"}, { "TATA", "TUTU" }, :title => "Titre" )
  def show_table_form(titles, champs, options = {})
    return "Error" unless titles and titles.size > 0
    return "Error" unless champs and champs.size > 0
    return "Error" unless titles.size == champs.size

    result = ""

    if(options[:title])
      result << "<h1>#{options[:title]}</h1>"
      result << "<br/>" unless options[:subtitle]
      result << "\n"
    end
    if(options[:subtitle])
      result << "<h2>#{options[:subtitle]}</h2><br>\n"
    end

    result << "<table>\n"
    for i in 0..titles.size
      unless champs[i].nil? and titles[i].nil?
        result << "<tr>\n"
        if champs[i].nil? or titles[i].nil?
          value = ( champs[i] ? champs[i].to_s : titles[i].to_s )
          result << "<td colspan=\"2\">" << value << "</td>\n"
        else
          result << "<td>" << titles[i].to_s << "</td>\n"
          result << "<td>" << champs[i].to_s << "</td>\n"
        end
        result << "</tr>\n"
      end
    end
    result << "</table>\n"
  end

  # Collection doit contenir des objects qui ont un 'id' et un 'nom'
  # objectcollection contient le tableau des objects déjà présents
  # C'est la fonction to_s qui est utilisée pour le label
  # Ex : hbtm_radio_button( @logiciel.competences, @competences, 'competence_ids') 
  def hbtm_radio_button( objectcollection, collection, nom )
    return '' if collection.nil?
    out = ""
    for donnee in collection
      out << "<input type=\"radio\" id=\"#{donnee.id}\" "
      out << "name=\"#{nom}[]\" value=\"#{donnee.id}\" "
      out << 'checked="checked" ' if objectcollection and objectcollection.include? donnee
      out << "> #{donnee} </input>"
    end
    out
  end

end
