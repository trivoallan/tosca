module ReportingHelper

  def fill_titles(data, size)
    titres = [@annee]
    size.times do |t|
      titres.push data[t][0].to_s.capitalize
    end
    titres
  end

  # options : one_row, muli_row et titre
  def report_table(nom, options={})
    table = ''
#    table << '<table width="100%">'
#    table << '<tr>'
#    table << '<td align="center">'
    if options[:titre]
      table << image_tag(@path[nom], :alt => options[:titre])
    else
      table << image_tag(@path[nom], :alt => @titres[nom])
    end
#    table << '</td>'
#    table << '<td align="center">'

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
    table << show_table(first_col, Demande, fill_titles(data, size)) { |date|
      result = ''
      result << "<td>#{date}</td>"
      size.times do |t|
        value = data[t][i]
        if value.is_a? Numeric
          result << "<td>#{sprintf('%.2f', value)}</td>"
        else
          result << "<td>#{value}</td>"
        end
      end
      i += 1
      result
    }
#    table << '</td>'
#    table << '</tr>'
#    table << '</table'
    table
  end

end
