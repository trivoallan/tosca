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
  @@couleurs_degradees = ( [nil] << colors ).flatten
  @@couleurs = ( [nil] << colors.values_at(1, 3, 5, 7, 9) ).flatten
  # Subset for specific graphs
  @@couleurs_delais = ( [nil] << colors.values_at(7, 1) ).flatten
  @@couleurs_types = ( [nil] << colors.values_at(3, 7, 9) ).flatten
  @@couleurs_types_degradees = ( [nil] << colors.values_at(2, 3, 6, 7, 8, 9) ).flatten

  # allows to launch activity report
  def configuration
    _titles()
    @contracts = (@recipient ? @recipient.client.contracts :
                 Contract.find(:all, Contract::OPTIONS))
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
      @time.end_of_month, @time.beginning_of_month ]

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
      @contract and (@report[:start_date] < @report[:end_date])
    init_data_general
    fill_data_general

    # TODO : trouver un bon moyen de faire un cache
    @data.each_pair do |name, data| # each_key do |name|
      #sha1 = Digest::SHA1.hexdigest("-#{qui}-#{name}-")
      @path[name] = "reporting/#{name}.png"
      size = data.size
      if (not data.empty? and data[0].to_s =~ /_(terminees|en_cours)/)
        # cas d'une légende à deux colonnes : degradé obligatoire
        if name.to_s =~ /^severite/
          @colors[name] = @@couleurs_degradees[1..size]
        elsif name.to_s =~ /^repartition/
          @colors[name] = @@couleurs_types_degradees[1..size]
        else
          @colors[name] = @@couleurs_degradees[1..size]
        end
      else
        # cas d'une légende à une colonne : pas de degradé
        if name.to_s =~ /^temps/
          @colors[name] = @@couleurs_delais[1..size]
        elsif name.to_s =~ /^annulation/
          @colors[name] = @@couleurs_types[1..size]
        else
          @colors[name] = @@couleurs[1..size]
        end
      end
    end


    #on nettoie
    # TODO retravailler le nettoyage
    # reporting = File.expand_path('public/reporting', RAILS_ROOT)
    # rmtree(reporting)
    # Dir.mkdir(reporting)

    # on remplit
    i_want_to_draw_graphs = true
    if (i_want_to_draw_graphs)
      write3graph(:repartition, Gruff::StackedBar)
      write3graph(:severite, Gruff::StackedBar)
      write3graph(:resolution, Gruff::StackedBar)

      write3graph(:evolution, Gruff::Line)
      write3graph(:annulation, Gruff::Bar)

      write3graph(:callback_time, Gruff::Line)
      write3graph(:workaround_time, Gruff::Line)
      write3graph(:correction_time, Gruff::Line)
    end

    #     write_graph(:top5_issues, Gruff::Pie)
    #     write_graph(:top5_softwares, Gruff::Pie)
    # on nettoie
    @first_col.each { |c| c.gsub!('\n','') }
  end

  private

  # initialise toutes les variables de classes nécessaire
  # path stocke les chemins d'accès, @données les données
  # @first_col contient la première colonne et @contract le contract
  # sélectionné
  def init_class_var(params)
    period =  params[:reporting][:period].to_i
    return unless period > 0
    @contract = Contract.find(params[:reporting][:contract_id].to_i)
    @data, @path, @report, @colors = {}, {}, {}, {}
    @titles = @@titles
    @report[:start_date] = [ @contract.start_date.beginning_of_month,
                             Time.now ].min
    @report[:end_date] = [ calendar2time(params[:end_date]),
                           @contract.end_date.beginning_of_month].min
    @first_col = []
    current_month = @report[:start_date]
    end_date = @report[:end_date]
    while (current_month <= end_date) do
      @first_col.push current_month.strftime('%b \n%Y')
      current_month = current_month.advance(:months => 1)
    end
    @labels = {}
    i = 0
    @first_col.each do |c|
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
      # condition de sortie
      @contract = nil
    end
  rescue
    flash.now[:warn] = _('incorrect parameters')
    @contract = nil
  end

  # initialisation de @data
  def init_data_general
    # Répartions par mois (StackedBar)
    # _terminees doit être en premier
    @data[:repartition]  =
     [ [:informations_terminees], [:anomalies_terminees],
     [:evolutions_terminees], [:informations_en_cours],
     [:anomalies_en_cours], [:evolutions_en_cours] ]
    @data[:severite] =
     [ [:bloquantes_terminees], [:majeures_terminees],
     [:mineures_terminees], [:sans_objet_terminees],
     [:bloquantes_en_cours], [:majeures_en_cours],
     [:mineures_en_cours], [:sans_objet_en_cours] ]
    @data[:resolution] =
     [ [:'contournées'], [:'corrigées'], [:'cloturées'], [:'annulées'], [:en_cours] ]
    @data[:evolution] =
     [ [:'bénéficiaires'], [:softwares], [:contributions] ] # TODO : [:interactions]
    @data[:annulation] =
     [ [:informations], [:anomalies], [:'évolutions'] ]

    # calcul des délais
    @data[:callback_time] =
     [ [:'délais_respectés'], [:'hors_délai'] ]
    @data[:workaround_time] =
     [ [:'délais_respectés'], [:'hors_délai'] ]
    @data[:correction_time] =
     [ [:'délais_respectés'], [:'hors_délai'] ]


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
      ponderation = (key.to_s =~ /^temps/) ? true : false
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

    issues = [ 'issues.created_on BETWEEN ? AND ? AND issues.contract_id = ?',
                 nil, nil, @contract.id ]
    until (start_date > end_date) do
      infdate = "#{start_date.strftime('%y-%m')}-01"
      start_date = start_date.advance(:months => 1)
      supdate = "#{start_date.strftime('%y-%m')}-01"

      issues[1], issues[2] = infdate, supdate
      Issue.send(:with_scope, { :find => { :conditions => issues } }) do
        compute_repartition @data[:repartition]
        compute_severite @data[:severite]
        compute_resolution @data[:resolution]
        compute_annulation @data[:annulation]
        compute_temps @data
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
  def compute_temps(data)
    issues = Issue.find(:all)
    rappels = data[:callback_time]
    workarounds = data[:workaround_time]
    corrections = data[:correction_time]
    last_index = rappels[0].size
    2.times {|i|
      rappels[i].push 0.0
      workarounds[i].push 0.0
      corrections[i].push 0.0
    }

    size = 0
    issues.each do |d|
      c = d.commitment
      interval = d.contract.interval.hours
      next unless c

      elapsed = d.elapsed
      fill_one_report(rappels, elapsed.taken_into_account,
                      1.hour, last_index)
      fill_one_report(workarounds, elapsed.workaround,
                      c.workaround * interval, last_index)
      fill_one_report(corrections, elapsed.correction,
                      c.correction * interval, last_index)
      size += 1
    end

    if size > 0
      size = size.to_f
      2.times {|i|
        rappels[i][last_index] = (rappels[i][last_index].to_f / size) * 100
        workarounds[i][last_index] = (workarounds[i][last_index].to_f / size) * 100
        corrections[i][last_index] = (corrections[i][last_index].to_f / size) * 100
      }
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


  ##
  # TODO : le faire marcher si y a moins de 5 softwares
  # Sort les 5 softwares qui ont eu le plus de issues
  def compute_top5_softwares(report)
    softwares = Issue.count(:group => "software_id")
    softwares = softwares.sort {|a,b| a[1]<=>b[1]}
    5.times do |i|
      values = softwares.pop
      name = Software.find(values[0]).name
      report.push [ name.intern ]
      report[i].push values[1]
    end
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
  def compute_annulation(report)
    # TODO : faire des requêtes paramètrées, avec des ?
    informations = { :conditions => [ 'statut_id = 8 AND typeissue_id = ?', 1 ] }
    anomalies = { :conditions => [ 'statut_id = 8 AND typeissue_id = ?', 2 ] }
    evolutions = { :conditions => [ 'statut_id = 8 AND typeissue_id = ?', 5 ] }

    report[0].push Issue.count(informations)
    report[1].push Issue.count(anomalies)
    report[2].push Issue.count(evolutions)
  end


  ##
  # Compte les issues selon leur nature
  def compute_repartition(report)
    # TODO : faire des requêtes paramètrées, avec des ?
    informations = { :conditions => "typeissue_id = 1" }
    anomalies = { :conditions => "typeissue_id = 2" }
    evolutions = { :conditions => "typeissue_id = 5" }

    Issue.send(:with_scope, { :find => { :conditions => Issue::TERMINEES } }) do
      report[0].push Issue.count(informations)
      report[1].push Issue.count(anomalies)
      report[2].push Issue.count(evolutions)
    end

    Issue.send(:with_scope, { :find => { :conditions => Issue::EN_COURS } }) do
      report[3].push Issue.count(informations)
      report[4].push Issue.count(anomalies)
      report[5].push Issue.count(evolutions)
    end
  end

  ##
  # Compte les issues par sévérités
  def compute_severite(report)
    severites = []
    # TODO : requête paramètréé, avec ?
     (1..4).each do |i|
      severites.concat [ { :conditions => "severite_id = #{i}" } ]
    end

    Issue.send(:with_scope, { :find => { :conditions => Issue::TERMINEES } }) do
      4.times do |t|
        report[t].push Issue.count(severites[t])
      end
    end
    Issue.send(:with_scope, { :find => { :conditions => Issue::EN_COURS } }) do
      4.times do |t|
        report[t+4].push Issue.count(severites[t])
      end
    end
  end

  ##
  # Compte le nombre de issue Annulée, Cloturée ou en cours de traitement
  def compute_resolution(report)
    condition = 'issues.statut_id = ?'
    contournee = { :conditions => [condition, 5] }
    corrigee = { :conditions => [condition, 6] }
    cloturee = { :conditions => [condition, 7] }
    annulee = { :conditions => [condition, 8] }
    en_cours = { :conditions => 'statut_id NOT IN (5,6,7,8)' }

    report[0].push Issue.count(contournee)
    report[1].push Issue.count(corrigee)
    report[2].push Issue.count(cloturee)
    report[3].push Issue.count(annulee)
    report[4].push Issue.count(en_cours)
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

    data = @data[name].sort{|x,y| x[0].to_s <=> y[0].to_s}
    data.each {|value| g.data(value[0], value[1..-1]) }
    g.labels = @labels
    g.hide_dots = true if g.respond_to? :hide_dots
    g.hide_legend = true
    # TODO : mettre ca dans les metadatas
    g.no_data_message = _("No data \navailable")

    # this writes the file to the hard drive for caching
    g.write "#{RAILS_ROOT}/public/images/#{@path[name]}"
  end


  # todo : une variable de classe localise (@@titles[locale])
  def _titles
    @@titles = {
      :repartition => _('Distribution of your issues'),
      :repartition_cumulee => _('Distribution of issues'),
      :severite => _('Severity of your issues'),
      :severite_cumulee => _('Severity of your issues'),
      :resolution => _('Resolution of your issues'),
      :resolution_cumulee => _('Resolution of your issues'),

      :annulation => _('Cancelled issues'),
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
