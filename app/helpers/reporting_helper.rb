module ReportingHelper

  def fill_titles(data, size)
    titres = ['Période']
    size.times do |t|
      titres.push data[t][0]
    end
    titres
  end

  def report_table(nom, options={})
    table = ''
    table << '<table width="100%">'
    table << '<tr>'
    table << '<td align="center">'
    table << image_tag(@path[nom], :alt => @titres[nom])
    table << '</td>'
    table << '<td align="center">'

    first_col = (options[:one_row] ? ['<b>Total</b>'] : @first_col)

    data = @donnees[nom]
    size = data.size
    unless options[:one_row]
      last_line = []
      size.times do |t|
        data[t].push data[t][1..-1].inject(0) {|n, value| n + value }
      end
    end
    i = 1
    table << show_table(first_col, Demande, fill_titles(data, size)) { |date|
      result = ''
      result << "<td>#{date}</td>"
      size.times do |t|
        result << "<td>#{data[t][i]}</td>"
      end
      i += 1
      result
    }
    table << '</td>'
    table << '</tr>'
    table << '</table'
    table
  end

end
