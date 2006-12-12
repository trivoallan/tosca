module ReportingHelper

  def fill_titles(data, size)
    titres = ['']
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

    data = @donnees[nom]
    size = data.size

    if options[:one_row]
      first_col = ['<b>Total</b>']
    elsif options[:multi_row]
      first_col = data[0][1..-1]
    else
      first_col = @first_col
    end
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
