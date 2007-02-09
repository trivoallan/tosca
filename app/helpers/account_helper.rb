#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module AccountHelper

  # Titles doit contenir un tableau
  # Champs doit contenir un tableau
  # Les éléments de Titles et Champs doivent être affichable par to_s
  # Les options sont 
  #         :title => Donne un titre au tableau
  # Ex : show_table_form( { "TOTO", "TITI"}, { "TATA", "TUTU" }, :title => "Titre" )
  def show_table_form(titles, champs, options = {})
    return "Error" unless titles and titles.size > 0
    return "Error" unless champs and champs.size > 0
    return "Error" unless titles.size == champs.size

    result = ""

    if(options[:title])
      result << "<h1>#{options[:title]}</h1><br>\n"
    end

    result << "<table>\n"

    for i in 0..titles.size
      if not champs[i].nil? or not titles[i].nil?
        result << "<tr>\n"
        if champs[i].nil? or titles[i].nil?
          if champs[i]
            value = champs[i].to_s
          else
            value = titles[i].to_s
          end
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
