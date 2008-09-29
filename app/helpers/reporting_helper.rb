#
# Copyright (c) 2006-2008 Linagora
#
# This file is part of Tosca
#
# Tosca is free software, you can redistribute it and/or modify
# it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
# Tosca is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
module ReportingHelper

  # Renvoit les titres du tableau
  # Data contient les entêtes. Les options applicable sont :
  # :without_firstcol => permet de ne pas afficher la première colonne
  # :divise => spécifie si on prends en compte les issues vivantes
  # :with2rows => affichera les entêtes sur 2 lignes, il <b>contient</b> l'intitulé
  # TODO : renommer with2rows en title
  def fill_titles(data, options)
    size = (options[:divise] ? data.size / 2 : data.size)
    result = ''
    return result unless size > 0
    result << '<tr>'
    first = _('Period')
    if options[:with2rows]
      result << "<th rowspan=\"2\">#{first}</th>"  unless options[:without_firstcol]
      result << "<th nowrap colspan=\"#{size}\"><center>#{options[:with2rows]}</center></th>"
      result << '</tr><tr>'
      size.times do |t|
        result << '<th nowrap>'
        result << data[t][0].to_s.gsub(/_(terminees|en_cours)/, '').gsub('_','&nbsp;').capitalize
        result << '</th>'
      end
    else
      titres = []
      titres.push first unless options[:without_firstcol]
      size.times do |t|
        titres.push data[t][0].to_s.gsub('_', '&nbsp;').capitalize
      end
      titres.each {|t| result << "<th nowrap>#{t}</th>" }
    end
    result << '</tr>'
  end

  # élément de reporting : 2 cellules
  # options : one_row, muli_row et titre
  def report_evolution(name, options={})
    data = @data[name]
    if (not data.empty? and data[0].to_s =~ /_(terminees|en_cours)/)
      options.update(:divise => true)
    end
    table = ''
#    table << '<div id="left">'
    table << '<table width="100%">'
    table << ' <tr>'

    # cellule contenant le graphique
    table << '  <td class="report_graph">'
    table <<    report_graph(name, options) unless name.to_s =~ /^temps/
    table << '  </td>'
#    table << '</div>'

    # cellule avec la légende
#    table << '<div id="middle">'
    table << '  <td class="report_legend">'
    table <<    report_legend(name)
    table << '  </td>'
#    table << '</div>'
    # cellule contenant le tableau de données
#    table << '<div id="right">'
    table << '  <td class="report_data">'
    table <<    report_data(name, options)
    table << '  </td>'
#    table << '</div>'

    table << ' </tr>'
    table << '</table>'
    table
  end


  # permet de comparer deux graphiques :
  # - l'un concernant la periode considérée (à gauche)
  # - l'autre concernant la totalité depuis le début du contract
  # TODO : style : center report_item tr td
  def report_repartition(name, options= {})
    data = @data[name]
    if (not data.empty? and data[0].to_s =~ /_(terminees|en_cours)/)
      options.update(:divise => true)
    end
    middle = :"#{name}_middle"
    total = :"#{name}_total"
    table = ''
    table << '<table class="report_item">'
    table << ' <tr>'
    # cellule contenant le graphique de la periode
    table << '  <td class="report_graph" align="center">'
    table << '  ' + _('During the chosen period')
    table <<    report_graph(middle, options)
    table << '  </td>'
    # cellule avec la légende
    table << '  <td class="report_legend">'
    table <<    report_legend(name)
    table << '  </td>'
    # cellule contenant le graphique depuis le début
    table << '  <td class="report_data" align="center">'
    table << '  ' + _('Since the begining of your contract')
    table <<    report_graph(total, options)
    table << '  </td>'
    table << ' </tr>'

    # pas de deuxieme partie pour les calculs des delais
    # (% affichés dans la première)
    unless (name.to_s =~ /^temps/)
      options.update(:without_firstcol => true)
      table << ' <tr>'
      # cellule contenant le graphique
      table << '  <td class="report_data" align="center">'
      table <<    report_data(middle, options)
      table << '  </td>'
      # cellule vide
      table << '<td></td>'
      # cellule contenant le tableau de données
      table << '  <td class="report_data" align="center">'
      table <<    report_data(total, options)
      table << '  </td>'
      table << ' </tr>'
    end
    table << '</table>'
    table
  end

  def report_legend(name)
    out = ''
    data = @data[name].sort{|x,y| x[0].to_s <=> y[0].to_s}
    colors = @colors[name]
    return out unless colors and colors.size > 0

    out << '<table align="center">'
    if (not data.empty? and data[0].to_s =~ /_(terminees|en_cours)/)
      twolines = true
      size = data.size / 2
    else
      twolines = false
      size = data.size
    end

    # TODO : put backgrounded cells into the static image helper ?
    # We can then remove the code below
    relative_url_root = "#{Static::ActionView.relative_url_root}reporting/"
    size.times do |i|
      index = (twolines ? i*2 : i)
      name = data[index][0].to_s
      head = name.gsub(/_(terminees|en_cours)/, '').gsub('_','&nbsp;').capitalize
      out << "<tr><th #{'colspan="2"' if twolines}>#{head}</th></tr>"
      out << "<tr><th>#{_('Running')}</th><th>#{_('Finished')}</th></tr>" if twolines
      out << '<tr>'
      color = colors[index]
      # un <td> quoiqu'il se passe
      out << "<td bgcolor=\"#{color}\"><img src=\"#{relative_url_root}#{color.gsub('#','x')}.png\" alt=\"#{color}\"/>&nbsp;</td>"
      # un autre si twolines
      if twolines
        color = colors[index+1]
        out << "<td bgcolor=\"#{color}\"><img src=\"#{relative_url_root}#{color.gsub('#','x')}.png\" alt=\"#{color}\"/>&nbsp;</td>"
      end
      out << '</tr>'
    end
    out << '</table>' # << '</tr>'
  end

  # graphique
  # options : titre
  def report_graph(name, options={})
    out = ''
    if options[:titre]
      out << image_tag(@path[name], :alt => options[:titre])
    else
      out << image_tag(@path[name], :alt => @titles[name])
    end
    out
  end

  # tableau de données
  # options : one_row, muli_row
  def report_data(name, options={})
    out = ''
    data = @data[name]
    if options[:without_firstcol]
      first_col = [nil]
    else
      first_col = @first_col
    end
    options.update(:width => '5%')
    out << show_report_table(first_col, name,
                             fill_titles(data, options),
                             options)
    out
  end

  # Print reporting tables
  # options are :
  # :without_firstcol : disabled the column with the dates
  # :divise : display only half of the columns
  # :width : force the width
  # TODO : first_col, options[:without_firstcol] : needs more love
  def show_report_table(first_col, name, titres, options = {})
    elements = @data[name]
    return 'aucune donnée' unless elements and elements.size > 0
    width = ( options[:width] ? "width=#{options[:width]}" : '' )
    result = "<table #{width}>"
    result << titres

    size = (options[:divise] ? (elements.size / 2) : elements.size)

    first_col.each_index { |i|
      result << "<tr class=\"#{cycle('even', 'odd')}\">"
      result << "<td>#{first_col[i]}</td>"  unless options[:without_firstcol]

      size.times do |c|
        en_cours = (options[:divise] ? elements[c+size][i + 1] : 0)
        total = elements[c][i + 1] + en_cours
        if (total.is_a? Float)
            total = (total==0.0 ? '-' : "#{total.round}\%")
        end
        result << "<td>#{total}"
        result << " (#{en_cours})" if en_cours != 0
        result << "</td>"
      end
      i += 1
      result << '</tr>'
    }
    result << '</table>'
  end

  # TODO : find 3 images. Maybe include this helper in static image  ??
  def progress_image( status, percent )
    return StaticImage.sla_exceeded if percent > 1.0
    return StaticImage.sla_ok if status
    StaticImage.sla_running
  end

  # Display a progress bar colored according to the percentage given in
  # argument. 0% correspond to green, 100% to red and > 100% to black
  # usage : progress_bar(50) display a orange bar, which correspond to 50%
  def progress_bar( percent, desc = _('progress bar') )
    return '-' if (not percent.is_a? Numeric or percent <= 0)
    percent = (percent * 100)
    case percent
    when percent < 0
      percent = 0
    when 0..50.0
      red, green = (255*percent/50.0).round , 255
    when 50.0..100.0
      red , green = 255, (255*(100-percent)/50.0).round
    else
      red, green = 0, 0
    end

    color = "rgb( #{red}, #{green},0)"

    result = image_percent(1.23*percent, color, desc)
    result << " (#{(percent).round} %) " if @ingenieur
    result
  end

  def progress_text(elapsed, total, interval)
    result = Time.in_words(elapsed, interval)
    return result if elapsed == 0
    elapsed = Elapsed.relative2absolute(elapsed, interval)
    return _('Exceedance') if @recipient && elapsed > total
    result += " / #{Time.in_words(total)}"
  end

  #display a select box with all clients.
  #number_items defines the number of visible items in the drop-down list

  # TODO : We need to put the find in the controller
  #        and to rewrite this ugly method and put it into forms_helper
  # call it like this :
  # <%= box_clients(9) %> will show a multi-selection box
  #                       with 9 selectable items
  def box_clients(number_items)
    elements = Client.find(:all, :select => 'id,name', :order => 'name')
    items='<option value=\'all\' selected=\'selected\'>»</option>'

    elements.each do |elt|
      items << '<option value=\'' << elt.id.to_s << '\'>'
      items << elt.name
      items << '</option>'
    end
    return '<select id=\'clients\' multiple=\'multiple\' name=\'clients[]\' size="' << number_items.to_s << '">' <<  items << '</select>'
  end



  # Display nicely the issues for the weekly report. See
  # reporting/weekly.rhtml for more information.
  # It takes a list of issues, where client and recipients are preloaded.
  def display_weekly_issues(issues)
    client = nil
    result = '<ol>'
    issues.each do |r|
      if client != r.recipient.client
        result << '</li>' unless client.nil?
        client = r.recipient.client
        result << "<li><b>#{ client.name}</b> :"
      end
      result << ' ' << link_to(r.id.to_s, issue_path(r))
    end
    result << '</li>' if client
    result << '</ol>'
    result
  end

  # Remove some common pattern from a text, in order to reduce it
  # as far as it is possible
  def digest_text(text, size)
    text = html2text(text)
    text.gsub!(/(b|B)onjour.*$/, "")
    text.gsub!(/(c|C)ordialement.*$/, "")
    text.squeeze!(' ') # remove multiple successive whitespace
    text.strip! # remove leading and trailing whitespace removed.
    truncate(text, size)
  end

end
