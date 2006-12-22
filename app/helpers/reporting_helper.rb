module ReportingHelper

  def fill_titles(data, size)
    titres = [@annee]
    size.times do |t|
      titres.push data[t][0].to_s.capitalize
    end
    titres
  end

  # élément de reporting : 2 cellules
  # options : one_row, muli_row et titre
  def report_item(nom, options={})
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
    data = @donnees[nom]
    size = data.size
    if options[:one_row]
      first_col = ['<b>Moyenne</b>']
    elsif options[:multi_row]
      first_col = data[0][1..-1]
    else
      first_col = @first_col
    end
    if options[:total_row]
      size.times do |t|
        data[t].push data[t][1..-1].inject(0) {|n, value| n + value }
      end
    end
    i = 1
    out << show_table(first_col, Demande, fill_titles(data, size), :width => "100%") { |date|
      result = ''
      result << "<td>#{date}</td>"
      size.times do |t|
        value = data[t][i]
        if value.is_a? Float
          result << "<td>#{sprintf('%.2f', value)}</td>"
        else
          result << "<td>#{value}</td>"
        end
      end
      i += 1
      result
    }
    out
  end 

end
