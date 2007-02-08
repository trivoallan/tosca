#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module AccountHelper

  def show_table_form(titles, champs, options = {})
    return "Error" unless titles and titles.size > 0
    return "Error" unless champs and champs.size > 0
    return "Error" unless titles.size == champs.size

    result = ""

    if(options[:title])
      result << "<h1>#{options[:title]}</h1><br>"
    end

    result << "<table>"

    for i in 0..titles.size
      if not champs[i].nil? or not titles[i].nil?
        result << "<tr>"
        if champs[i].nil? or titles[i].nil?
          if champs[i]
            value = champs[i].to_s
          else
            value = titles[i].to_s
          end
          result << '<td colspan="2">' << value << "</td>"
        else
          result << "<td>" << titles[i].to_s << "</td>"
          result << "<td>" << champs[i].to_s << "</td>"
        end
        result << "</tr>"
      end
    end

    result << "</table>"
  end


end
