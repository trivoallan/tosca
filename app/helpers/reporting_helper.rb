module ReportingHelper

  def report_table(nom)
    table = ''
    table << '<table width="100%">'
    table << '<tr>'
    table << '<td align="center">'
    table << image_tag(@path[nom], :alt => @titres[nom]) 
    table << '</td>'
    table << '<td align="center">'
    titres = ['Période']
    size = @historiques[nom].size
    size.times do |t|
      titres.push @historiques[nom][t][0]
    end
    table << show_table(@dates.sort, Demande, titres) { |i, date|
      result = ''
      result << "<td>#{date}</td>"
      size.times do |t|
          result << "<td>#{@historiques[nom][t][i+1]}</td>"
        end
        if i == 11
          result << '<tr>'
          result << "<td><b>2006</b></td>"
          size.times do |t|
            sum = @historiques[nom][t][1..-1].inject(0) {|n, i| n + i }
            result << "<td>#{sum}</td>"
          end
          result << '</tr>'
        end
        result
    }
    table << '</td>'
    table << '</tr>'
    table << '</table>'
    table
  end

end
