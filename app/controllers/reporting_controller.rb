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
class ReportingController < ApplicationController
  helper :issues, :export
  include WeeklyReporting
  include DigestReporting

  # Default colors are distributed by alphabetical order of severity
  # ( blocking, major, minor, none )
  # TODO : implement a better solution, with a hash ?
  colors =  [
    # dark,    # light,   # colour
    "#ff2222", "#dd0000", # red
    "#ffa464", "#dd8242", # orange
    "#ffff22", "#dddd00", # yellow
    "#a6ff22", "#84dd00", # green
    "#22a4ff", "#0082dd", # blue
  ]
  # Array starts at 0, but Gruff need a start at 1
  @@distinct_colors = ( [nil] << %w(#330065 #343397 #3399fe #339898 #339833 #99cb33
      #fefe33 #fecb33 #fe9933 #fc3301 #fc3365 #970264) ).flatten
  @@colors = ( [nil] << colors.values_at(2,3, 4,5, 6,7, 8,9, 0,1) ).flatten
  # Subset for specific graphs
  @@sla_colors = ( [nil] << colors.values_at(7, 1) ).flatten
  @@severity_colors = ( [nil] << colors.values_at(0,1, 2,3, 4,5, 6,7) ).flatten
  @@colors_types = ( [nil] << colors.values_at(3, 7, 9) ).flatten
  @@type_colors = ( [nil] << colors.values_at(2, 6, 8, 3, 7, 9) ).flatten

  # allows to launch activity report
  def configuration
    @contracts = session[:user].contracts.sort!{|a, b| a.name <=> b.name}
  end

  # To display new issues by months
  def calendar
    #Get the parameters
    month = Time.today.month
    month = params[:month] if params.has_key? :month
    year = Time.today.year
    year = params[:year] if params.has_key? :year
    @time = Time.mktime(year, month)

    conditions = [ 'created_on BETWEEN ? AND ?',
      @time.beginning_of_month, @time.end_of_month ]

    # Adapt it ?
    # SELECT DAYOFMONTH(issues.created_on), GROUP_CONCAT(id), GROUP_CONCAT(resume)
    #   FROM issues
    #   WHERE (created_on BETWEEN '2007-10-01 00:00:00' AND '2008-11-30 23:59:59')
    #   GROUP BY DAYOFMONTH(issues.created_on);
    issues = Issue.find(:all, :conditions => conditions)
    @number_issues = issues.size

    #We build a hash of { number_day => [new issues of the day]}
    @issues = {}
    issues.each do |r|
      @issues[r.created_on.day] ||= Array.new
      @issues[r.created_on.day].push(r)
    end
  end

  def digest
  end

  def digest_resultat
    render :nothing => true and return unless params.has_key? :digest
    digest_result(params[:digest][:period])
  end

  def general
    _titles()
    redirect_to configuration_reporting_path and return unless
      params[:reporting]

    init_class_var(params)
    redirect_to configuration_reporting_path and return unless
      @contracts and (@report[:start_date] < @report[:end_date])
    init_data_general
    fill_data_general

    init_colors

    #on nettoie
    # TODO retravailler le nettoyage
    # reporting = File.expand_path('public/reporting', RAILS_ROOT)
    # rmtree(reporting)
    # Dir.mkdir(reporting)

    # writing graph on disk
    i_want_to_draw_graphs = true
    if (i_want_to_draw_graphs)
      write3graph(:by_type, Gruff::StackedBar)
      write3graph(:by_severity, Gruff::StackedBar)
      write3graph(:by_status, Gruff::StackedBar)
      write3graph(:by_software, Gruff::StackedBar)

      write3graph(:evolution, Gruff::Line)
      write3graph(:cancelled, Gruff::Bar)

      write3graph(:callback_time, Gruff::Line)
      write3graph(:workaround_time, Gruff::Line)
      write3graph(:correction_time, Gruff::Line)
    end

    #     write_graph(:top5_issues, Gruff::Pie)
    # on nettoie
    @months_col.each { |c| c.gsub!('\n','') }
  end

  private

  # initialise toutes les variables de classes nécessaire
  # path stocke les chemins d'accès, @données les données
  # @months_col contient la première colonne et @contract le contract
  # sélectionné
  def init_class_var(params)
    period =  params[:reporting][:period].to_i
    return unless period > 0
    @contracts = Contract.find(params[:reporting][:contract_ids].each(&:to_i))
    @data, @path, @report, @colors = {}, {}, {}, {}
    dates = @contracts.collect {|c| c.start_date.beginning_of_month}
    @report[:start_date] = (dates << Time.now).min
    dates = @contracts.collect {|c| c.end_date.beginning_of_month}
    @report[:end_date] = (dates << calendar2time(params[:end_date])).min
    @months_col = []
    current_month = @report[:start_date]
    end_date = @report[:end_date]
    while (current_month <= end_date) do
      @months_col.push current_month.strftime('%b \n%Y')
      current_month = current_month.advance(:months => 1)
    end
    @labels = {}
    i = 0
    @months_col.each do |c|
      @labels[i] = c if ((i % 2) == 0)
      i += 1
    end
    middle_date = end_date.months_ago(period)
    start_date = @report[:start_date]
    if (middle_date > start_date and middle_date < end_date)
      @report[:middle_date] = [ middle_date, start_date ].max.beginning_of_month
      @report[:middle_report] = period
      @report[:total_report] = compute_nb_month(start_date, end_date)
    else
      flash.now[:warn] = _('incorrect parameters')
      # out condition
      @contracts = nil
    end
  rescue
    flash.now[:warn] = _('incorrect parameters')
    @contracts = nil
  end

  # It's damn hard to compute a difference of month
  def compute_nb_month(start_date, end_date)
    end_date.month - start_date.month + 1 +
      (end_date.year - start_date.year) * 12
  end

  # Remplit un tableau avec la somme des données sur nb_month
  # Call it like : middle_period = compute_data_period('middle', 3)
  def compute_data_period(period, nb_month)
    start = -nb_month
    data = {}
    @data.each_key do |key|
      mykey = :"#{key}_#{period}"
      data[mykey] = []
      ponderation = (key.to_s =~ /^time/) ? true : false
      @data[key].each do |value|
        result = []
        result.push value[0]
        if ponderation
          result.push value[start..-1].inject(0){|s, v| s + v}
          result[result.size - 1] /= nb_month # total if total != 0
        else
          result.push value[start..-1].inject(0){|s, v| s + v}
        end
        data[mykey].push result
      end
    end
    data
  end

  def fill_data_general
    start_date = @report[:start_date]
    end_date = @report[:end_date]

    # We cannot know in advance what are the most important software
    init_compute_by_software(@data[:by_software])
    severites_filter = init_compute_by_severity
    init_compute_by_type
    issues = [ 'issues.created_on BETWEEN ? AND ? AND issues.contract_id IN (?)',
                 nil, nil, @contracts.collect(&:id) ]
    until (start_date > end_date) do
      infdate = "#{start_date.strftime('%y-%m')}-01"
      start_date = start_date.advance(:months => 1)
      supdate = "#{start_date.strftime('%y-%m')}-01"

      issues[1], issues[2] = infdate, supdate
      Issue.send(:with_scope, { :find => { :conditions => issues } }) do
        compute_by_type @data[:by_type]
        compute_by_severity @data[:by_severity], severites_filter
        compute_by_status @data[:by_status]
        compute_by_software @data[:by_software]
        compute_cancelled @data[:cancelled]
        compute_time @data
        compute_evolution @data[:evolution]
      end
    end

    # on fais bien attention à ne merger avec @data
    # qu'APRES avoir calculé toutes les sommes
    middle_report = compute_data_period('middle', @report[:middle_report] + 1)
    total_report = compute_data_period('total', @report[:total_report])

    # Maintenant on peut mettre à jour @data
    @data.update(middle_report)
    @data.update(total_report)
    #TODO : se débarrasser de cet héritage legacy
    #       compute_top5_softwares @data[:top5_softwares]
    #       Comment.with_scope({ :find => { :conditions => @conditions } }) do
    #         compute_top5_issues @data[:top5_issues]
    #       end
    #     end
  end


  ##
  # Calcul un tableaux du respect des délais
  # pour les 3 étapes : prise en compte, contournée, corrigée
  def compute_time(data)
    issues = Issue.find(:all)
    phonecalls = data[:callback_time]
    workarounds = data[:workaround_time]
    corrections = data[:correction_time]
    last_index = phonecalls[0].size
    2.times {|i|
      phonecalls[i].push 0.0
      workarounds[i].push 0.0
      corrections[i].push 0.0
    }

    size = 0
    issues.each do |d|
      c = d.commitment
      interval = d.contract.interval.hours
      next unless c

      elapsed = d.elapsed
      fill_one_report(phonecalls, elapsed.taken_into_account,
                      1.hour, last_index)
      fill_one_report(workarounds, elapsed.workaround,
                      c.workaround * interval, last_index)
      fill_one_report(corrections, elapsed.correction,
                      c.correction * interval, last_index)
      size += 1
    end

    size = size.to_f
    return unless size > 0
    2.times do |i|
      phonecalls[i][last_index] = (phonecalls[i][last_index].to_f / size) * 100
      workarounds[i][last_index] = (workarounds[i][last_index].to_f / size) * 100
      corrections[i][last_index] = (corrections[i][last_index].to_f / size) * 100
    end
  end

  # Petit helper pour être dry, je sais pas trop comment l'appeler
  def fill_one_report(collection, value, max, last)
    if ((value <= max) || (max < 0))
      collection[0][last] += 1
    else
      collection[1][last] += 1
    end
  end


  def init_compute_by_software(report)
    software = Issue.count(:group => "software_id", :conditions =>
                           { :contract_id => @contracts.collect(&:id) })
    software = software.sort {|a,b| a[1]<=>b[1]}
    @software_ids = []

    [ software.size, 10].min.times do |i|
      software_id = software.pop[0]
      next if software_id.nil?
      @software_ids << software_id
      name = Software.find(software_id).name
      report.push [ name ]
    end
    report.push [_('Unknown')]
    report.push [_('Others')]
  end

  ##
  #  Compute for each month which issues where on the top5 software
  def compute_by_software(report)
    index, total = 0, 0
    @software_ids.each do |i|
      count = Issue.count(:conditions => { :software_id => i})
      report[index].push count
      total += count
      index += 1
    end

    # Unknown software
    count = Issue.count(:conditions => { :software_id => nil })
    report[index].push count
    total += count
    index += 1

    # Others issues
    count = Issue.count
    report[index].push(count - total)
  end

  ##
  # TODO : le faire marcher si y a moins de 5 issues
  # Sort les 5 issues les plus commentées de l'année
  def compute_top5_issues(report)
    comments = Comment.count(:group => 'issue_id')
    comments = comments.sort {|a,b| a[1]<=>b[1]}
    5.times do |i|
      values = comments.pop
      name = values[0].to_s # "##{values[0]} (#{values[1]})"
      report.push [ name.intern ]
      report[i].push values[1]
    end
  end

  ##
  # Compte les issues annulées selon leur type
  def compute_cancelled(report)
    # TODO : faire des requêtes paramètrées, avec des ?
    informations = { :conditions => [ 'statut_id = 8 AND typeissue_id = ?', 1 ] }
    anomalies = { :conditions => [ 'statut_id = 8 AND typeissue_id = ?', 2 ] }
    evolutions = { :conditions => [ 'statut_id = 8 AND typeissue_id = ?', 5 ] }

    report[0].push Issue.count(informations)
    report[1].push Issue.count(anomalies)
    report[2].push Issue.count(evolutions)
  end


  def init_compute_by_type
    @types = Array.new
    @contracts.each do |c|
      @types.concat(c.client.typeissues)
    end
    @types.uniq!
  end

  ##
  # Compte les issues selon leur nature
  def compute_by_type(report)
    # 1st time, we have to fill dynamically labels
    # There's 2 lines, since we diffentiate opened and closed issues.
    if report.empty?
      @types.each { |type| report << [_(type.name)] }
      @types.each { |type| report << [:empty] }
    end

    Issue.send(:with_scope, { :find => { :conditions => Issue::OPENED } }) do
      @types.each_with_index do |type, i|
        conditions = { :conditions => { :typeissue_id => type.id } }
        report[i*2].push Issue.count(conditions)
      end
    end

    size = @types.size
    Issue.send(:with_scope, { :find => { :conditions => Issue::CLOSED } }) do
      @types.each_with_index do |type, i|
        conditions = { :conditions => { :typeissue_id => type.id } }
        report[i*2+1].push Issue.count(conditions)
      end
    end

  end

  def init_compute_by_severity()
    severities = Severity.all
    severities.each_with_index do |s, i|
      severities[i] = { :conditions => { :severity_id => s.id } }
    end
    severities
  end

  ##
  # Compte les issues par sévérités
  def compute_by_severity(report, filters)
    # 1st time, we have to fill dynamically labels
    # There's 2 lines, since we diffentiate opened and closed issues.
    if report.empty?
      severities = Severity.all
      severities.each { |s| report << [_(s.name)] }
      severities.size.times { report << [:empty] }
    end

    size = filters.size
    Issue.send(:with_scope, { :find => { :conditions => Issue::OPENED } }) do
      size.times do |t|
        report[t*2].push Issue.count(filters[t])
      end
    end

    Issue.send(:with_scope, { :find => { :conditions => Issue::CLOSED } }) do
      size.times do |t|
        report[t*2+1].push Issue.count(filters[t])
      end
    end
  end

  ##
  # Compte le nombre de issue Annulée, Cloturée ou en cours de traitement
  def compute_by_status(report)
    condition = 'issues.statut_id = ?'
    bypassed = { :conditions => [condition, 5] }
    fixed = { :conditions => [condition, 6] }
    closed = { :conditions => [condition, 7] }
    cancelled = { :conditions => [condition, 8] }
    active = { :conditions => 'statut_id NOT IN (5,6,7,8)' }

    report[0].push Issue.count(cancelled)
    report[1].push Issue.count(bypassed)
    report[2].push Issue.count(fixed)
    report[3].push Issue.count(closed)
    report[4].push Issue.count(active)
  end


  ##
  # Calcule le nombre de recipient, de software et contribution distinct par mois
  def compute_evolution(report)
    report[0].push Issue.count('recipient_id', :distinct => true)
    report[1].push Issue.count('software_id', :distinct => true)
    report[2].push Issue.count('contribution_id', :distinct => true)
  end


  # Lance l'écriture des _3_ graphes
  def write3graph(name, graph)
    __write_graph(name, graph)
    middle = :"#{name}_middle"
    __write_graph(middle, Gruff::Pie, _("Distributed on ") + "#{@report[:middle_report]}" + _(" months")) if @data[middle]
    total = :"#{name}_total"
    __write_graph(total, Gruff::Pie, _("Distributed on ") + "#{@report[:total_report]}" + _(" months")) if @data[total]
  end

  # Ecrit le graphe en utilisant les données indexées par 'name' dans @données
  # grâce au chemin d'accès spécifié dans @path[name]
  # graph sert à spécifier le type de graphe attendu
  def __write_graph(name, graph, title = _('Summary'))
    return unless @data[name]
    g = graph.new(450)

    # Trop confus pour l'utilisateur et plus de place pour le graphe
    # if title; g.title = title; else g.hide_title = true; end
    g.hide_title = true
    g.theme = { #    g.theme_37signals légèrement modifié
      :colors => @colors[name],
      :marker_color => 'black',
      :font_color => 'black',
      :background_colors => ['white', 'white']
    }
    g.sort = false

    data = @data[name] # .sort{|x,y| x[0].to_s <=> y[0].to_s}
    data.each {|value| g.data(value[0], value[1..-1]) }
    g.labels = @labels
    g.hide_dots = true if g.respond_to? :hide_dots
    g.hide_legend = true
    # TODO : mettre ca dans les metadatas
    g.no_data_message = _("No data \navailable")

    # this writes the file to the hard drive for caching
    g.write "#{RAILS_ROOT}/public/images/#{@path[name]}"
  end


  # 3 initialisations are needed : titles, colors & datas.
  def init_data_general
    # [:empty] are needed for helpers, which always consider that first column is a title one.
    @data[:by_type] = Array.new
    @data[:by_severity] = Array.new
    @data[:by_status] =
     [ [_('Cancelled')], [_('Bypassed')], [_('Fixed')], [_('Closed')], [_('Active')] ]
    @data[:by_status] =
     [ [_('Cancelled')], [_('Bypassed')], [_('Fixed')], [_('Closed')], [_('Active')] ]
    @data[:by_software] = Array.new

    @data[:evolution] =
     [ [_('Recipients')], [_('Softwares')], [_('Contributions')] ] # TODO : [:interactions]
    @data[:cancelled] =
     [ [_('Informations')], [_('Bugs')], [_('Evolutions')] ]

    # calcul des délais
    @data[:callback_time] =
     [ [_('In time')], [_('Out of time')] ]
    @data[:workaround_time] =
     [ [_('In time')], [_('Out of time')] ]
    @data[:correction_time] =
     [ [_('In time')], [_('Out of time')] ]

  end

  # 3 initialisations are needed : titles, colors & datas.
  def init_colors
    @data.each_pair do |name, data|
      # sha1 = Digest::SHA1.hexdigest("-#{qui}-#{name}-")
      # TODO : it's not safe to store it that way
      @path[name] = "reporting/#{name}.png"
      size = data.size
      case name.to_s
      when /by_type/
        @colors[name] = @@colors[1..@types.size*2]
      when /by_software/
        @colors[name] = @@distinct_colors[1..size]
      when /by_severity/
        @colors[name] = @@severity_colors[1..size]
      when /by_status/
        @colors[name] = @@distinct_colors[1..size]
      when /^cancelled/
        @colors[name] = @@colors_types[1..size]
      when /time/
        @colors[name] = @@sla_colors[1..size]
      else
        @colors[name] = @@colors[1..size]
      end
    end
  end


  # 3 initialisations are needed : titles, colors & datas.
  def _titles
    @titles = {
      :distribution => _('Distribution of your issues'),
      :by_type => _('By types'),
      :by_severity => _('By severities'),
      :by_status => _('By status'),
      :by_software => _('By software'),

      :cancelled => _('Cancelled issues'),
      :evolution => _('Evolution of the activity volume'),

      :top5_issues => _('Top 5 of the most discussed issues'),
      :top5_softwares => _('Top 5 of the most discussed software'),

      :processing_time => _('Processing time'),
      :callback_time => _('Response time'),
      :workaround_time => _('Workaround time'),
      :correction_time => _('Correction time')
    }
  end

end
