module ReportingHelper

  def fill_titles(data, size, options)
    return '' unless data.size > 0
    result = ''
    first = 'Période&nbsp;&nbsp;&nbsp;&nbsp;' 
    if data[0][0].to_s =~ /terminees/
      result << "<th rowspan=\"2\">#{first}</th>" unless options[:one_row]
      result << "<th nowrap colspan=\"#{size}\">Demandes</th>"
#      result << "<th nowrap colspan=\"#{size/2}\">En cours de traitement</th>"
      result << '</tr><tr>'
      size.times do |t|
        result << '<th>'
        result << data[t][0].to_s.gsub(/_(terminees|encours)/, '').gsub('_','&nbsp;').capitalize
        result << '</th>'
      end
    else
      titres = []
      titres.push first unless options[:one_row]
      size.times do |t|
        titres.push data[t][0].to_s.gsub('_', '<br />').capitalize
      end
      titres.each {|t| result << "<th>#{t}</th>" }
    end
    result
  end

  # élément de reporting : 2 cellules
  # options : one_row, muli_row et titre
  def report_evolution(nom, options={})
    table = ''
    table << '<table class="report_item">'
    table << ' <tr>'

    # cellule contenant le graphique
    table << '  <td class="report_graph">'
    table <<    report_graph(nom, options) 
    table << '  </td>'
    # cellule contenant le tableau de données
    table << '  <td class="report_data">'
    table <<    report_data(nom, options)
    table << '  </td>'

    table << ' </tr>'
    table << '</table>'
    table
  end

  def report_repartition(nom, options= {})
    middle = :"#{nom}_middle"
    total = :"#{nom}_total"
    table = ''
    table << '<table class="report_item">'
    table << ' <tr>'
    # cellule contenant le graphique
    table << '  <td class="report_graph">'
    table <<    report_graph(middle, options) 
    table << '  </td>'
    # cellule contenant le tableau de données
    table << '  <td class="report_data">'
    table <<    report_graph(total, options)
    table << '  </td>'
    table << ' </tr>'

    options.update(:one_row => true)
    table << ' <tr>'
    # cellule contenant le graphique
    table << '  <td class="report_graph">'
    table <<    report_data(middle, options) 
    table << '  </td>'
    # cellule contenant le tableau de données
    table << '  <td class="report_data">'
    table <<    report_data(total, options)
    table << '  </td>'
    table << ' </tr>'

    table << '</table>'
    table
  end

  # graphique
  # options : titre
  def report_graph(nom, options={})
    out = ''
    if options[:titre]
      out << image_tag(@path[nom], :alt => options[:titre])
    else
      out << image_tag(@path[nom], :alt => @titres[nom])
    end
    out
  end 

  # tableau de données
  # options : one_row, muli_row
  def report_data(nom, options={})
    out = ''
    data = @data[nom]
    size = (options[:divise] ? data.size / 2 : data.size)
    if options[:one_row]
      first_col = ['<b>roh</b>']
    else
      first_col = @first_col
    end
    options.update(:width => '5%')
    out << show_report_table(first_col, nom, 
                             fill_titles(data, size, options), 
                             options) 
    out
  end 

  def show_report_table(first_col, nom, titres, options = {})
    elements = @data[nom]
    colors = @colors[nom]
    return 'aucune donnée' unless elements and elements.size > 0
    width = ( options[:width] ? "width=#{options[:width]}" : '' )
    result = "<table #{width}>"
    # C'est sensé dire au navigateur d'aligner sur la virgule
    # TODO : vérifier 
    result << '<colgroup><col><col align="char" char=","></colgroup>'
    result << "<tr>#{titres}</tr>" 


#     if colors.size > 0
#       result << '<tr>'
#       result << '<td></td>' unless options[:one_row]
#       elements.each_index do |i|
#         result << "<td bgcolor=\"#{colors[i]}\"></td>"
#       end
#       result << '</tr>'
#     end

    size = (options[:divise] ? (elements.size / 2) : elements.size)
    first_col.each_index { |i| 
      result << "<tr class=\"#{(i % 2)==0 ? 'pair':'impair'}\">"
      result << "<td>#{first_col[i]}</td>" unless options[:one_row]
      size.times do |c|
        encours = (options[:divise] ? elements[c+size][i + 1] : 0)
        total = elements[c][i + 1] + encours
        # dieu que c'est moche, j'ai honte
        if total.is_a? Float
          if encours != 0
            result << "<td>#{sprintf('%.2f (%.2f)', total, encours)}</td>"
          else
            result << "<td>#{sprintf('%.2f', total)}</td>"
          end
        else
          if encours != 0
            result << "<td>#{total} (#{encours})</td>"
          else
            result << "<td>#{total}</td>"
          end  
        end
      end
      i += 1
      result << '</tr>'
    }
    result << '</tr></table>'
    # result << show_total(elements.size, ar, options)
  end


end
