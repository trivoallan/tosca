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
  helper :demandes, :export
  include WeeklyReporting
  include DigestReporting

  # Les couleurs par défauts sont dans l'ordre alphabétique des severités :
  # ( bloquante, majeure, mineure, sans objet )
  # TODO : faire un hash @@couleurs{} contenant les tableaux
  colors =  [
  # clair,    foncé,    #couleur
    "#dd0000", "#ff2222", #rouge
    "#dd8242", "#ffa464", #orange
    "#dddd00", "#ffff22", #jaune
    "#84dd00", "#a6ff22", #vert
    "#0082dd", "#22a4ff", #bleu
  ]
  # les index de tableau commencent à 0
  @@couleurs_degradees = ( [nil] << colors ).flatten
  @@couleurs = ( [nil] << colors.values_at(1, 3, 5, 7, 9) ).flatten
  # on modifie ensuite pour les autres type de données :
  @@couleurs_delais = ( [nil] << colors.values_at(7, 1) ).flatten
  @@couleurs_types = ( [nil] << colors.values_at(3, 7, 9) ).flatten
  @@couleurs_types_degradees = ( [nil] << colors.values_at(2, 3, 6, 7, 8, 9) ).flatten

  # utilisé avant l'affichage
  def configuration
    _titles()
    @contracts = (@recipient ? @recipient.client.contracts :
                 Contract.find(:all, Contract::OPTIONS))
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

      write3graph(:temps_de_rappel, Gruff::Line)
      write3graph(:temps_de_contournement, Gruff::Line)
      write3graph(:temps_de_correction, Gruff::Line)
    end

    #     write_graph(:top5_demandes, Gruff::Pie)
    #     write_graph(:top5_logiciels, Gruff::Pie)
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
     [ [:'bénéficiaires'], [:logiciels], [:contributions] ] # TODO : [:interactions]
    @data[:annulation] =
     [ [:informations], [:anomalies], [:'évolutions'] ]

    # calcul des délais
    @data[:temps_de_rappel] =
     [ [:'délais_respectés'], [:'hors_délai'] ]
    @data[:temps_de_contournement] =
     [ [:'délais_respectés'], [:'hors_délai'] ]
    @data[:temps_de_correction] =
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

    demandes = [ 'demandes.created_on BETWEEN ? AND ? AND demandes.contract_id = ?',
                 nil, nil, @contract.id ]
    until (start_date > end_date) do
      infdate = "#{start_date.strftime('%y-%m')}-01"
      start_date = start_date.advance(:months => 1)
      supdate = "#{start_date.strftime('%y-%m')}-01"

      demandes[1], demandes[2] = infdate, supdate
      Demande.send(:with_scope, { :find => { :conditions => demandes } }) do
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
    middle_report = compute_data_period('middle', @report[:middle_report])
    total_report = compute_data_period('total', @report[:total_report])

    # Maintenant on peut mettre à jour @data
    @data.update(middle_report)
    @data.update(total_report)
    #TODO : se débarrasser de cet héritage legacy
    #       compute_top5_logiciels @data[:top5_logiciels]
    #       Commentaire.with_scope({ :find => { :conditions => @conditions } }) do
    #         compute_top5_demandes @data[:top5_demandes]
    #       end
    #     end
  end


  ##
  # Calcul un tableaux du respect des délais
  # pour les 3 étapes : prise en compte, contournée, corrigée
  def compute_temps(data)
    demandes = Demande.find(:all)
    rappels = data[:temps_de_rappel]
    workarounds = data[:temps_de_contournement]
    corrections = data[:temps_de_correction]
    last_index = rappels[0].size
    2.times {|i|
      rappels[i].push 0.0
      workarounds[i].push 0.0
      corrections[i].push 0.0
    }

    size = 0
    demandes.each do |d|
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
  # TODO : le faire marcher si y a moins de 5 logiciels
  # Sort les 5 logiciels qui ont eu le plus de demandes
  def compute_top5_logiciels(report)
    logiciels = Demande.count(:group => "logiciel_id")
    logiciels = logiciels.sort {|a,b| a[1]<=>b[1]}
    5.times do |i|
      values = logiciels.pop
      name = Logiciel.find(values[0]).name
      report.push [ name.intern ]
      report[i].push values[1]
    end
  end

  ##
  # TODO : le faire marcher si y a moins de 5 demandes
  # Sort les 5 demandes les plus commentées de l'année
  def compute_top5_demandes(report)
    commentaires = Commentaire.count(:group => 'demande_id')
    commentaires = commentaires.sort {|a,b| a[1]<=>b[1]}
    5.times do |i|
      values = commentaires.pop
      name = values[0].to_s # "##{values[0]} (#{values[1]})"
      report.push [ name.intern ]
      report[i].push values[1]
    end
  end

  ##
  # Compte les demandes annulées selon leur type
  def compute_annulation(report)
    # TODO : faire des requêtes paramètrées, avec des ?
    informations = { :conditions => [ 'statut_id = 8 AND typedemande_id = ?', 1 ] }
    anomalies = { :conditions => [ 'statut_id = 8 AND typedemande_id = ?', 2 ] }
    evolutions = { :conditions => [ 'statut_id = 8 AND typedemande_id = ?', 5 ] }

    report[0].push Demande.count(informations)
    report[1].push Demande.count(anomalies)
    report[2].push Demande.count(evolutions)
  end


  ##
  # Compte les demandes selon leur nature
  def compute_repartition(report)
    # TODO : faire des requêtes paramètrées, avec des ?
    informations = { :conditions => "typedemande_id = 1" }
    anomalies = { :conditions => "typedemande_id = 2" }
    evolutions = { :conditions => "typedemande_id = 5" }

    Demande.send(:with_scope, { :find => { :conditions => Demande::TERMINEES } }) do
      report[0].push Demande.count(informations)
      report[1].push Demande.count(anomalies)
      report[2].push Demande.count(evolutions)
    end

    Demande.send(:with_scope, { :find => { :conditions => Demande::EN_COURS } }) do
      report[3].push Demande.count(informations)
      report[4].push Demande.count(anomalies)
      report[5].push Demande.count(evolutions)
    end
  end

  ##
  # Compte les demandes par sévérités
  def compute_severite(report)
    severites = []
    # TODO : requête paramètréé, avec ?
     (1..4).each do |i|
      severites.concat [ { :conditions => "severite_id = #{i}" } ]
    end

    Demande.send(:with_scope, { :find => { :conditions => Demande::TERMINEES } }) do
      4.times do |t|
        report[t].push Demande.count(severites[t])
      end
    end
    Demande.send(:with_scope, { :find => { :conditions => Demande::EN_COURS } }) do
      4.times do |t|
        report[t+4].push Demande.count(severites[t])
      end
    end
  end

  ##
  # Compte le nombre de demande Annulée, Cloturée ou en cours de traitement
  def compute_resolution(report)
    condition = 'demandes.statut_id = ?'
    contournee = { :conditions => [condition, 5] }
    corrigee = { :conditions => [condition, 6] }
    cloturee = { :conditions => [condition, 7] }
    annulee = { :conditions => [condition, 8] }
    en_cours = { :conditions => 'statut_id NOT IN (5,6,7,8)' }

    report[0].push Demande.count(contournee)
    report[1].push Demande.count(corrigee)
    report[2].push Demande.count(cloturee)
    report[3].push Demande.count(annulee)
    report[4].push Demande.count(en_cours)
  end


  ##
  # Calcule le nombre de recipient, de logiciel et contribution distinct par mois
  def compute_evolution(report)
    report[0].push Demande.count('recipient_id', :distinct => true)
    report[1].push Demande.count('logiciel_id', :distinct => true)
    report[2].push Demande.count('contribution_id', :distinct => true)
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
      :repartition => _('Distribution of your requests'),
      :repartition_cumulee => _('Distribution of requests'),
      :severite => _('Severity of your requests'),
      :severite_cumulee => _('Severity of your requests'),
      :resolution => _('Resolution of your requests'),
      :resolution_cumulee => _('Resolution of your requests'),

      :annulation => _('Cancelled requests'),
      :evolution => _('Evolution of the activity volume'),

      :top5_demandes => _('Top 5 of the most discussed requests'),
      :top5_logiciels => _('Top 5 of the most discussed software'),

      :processing_time => _('Processing time'),
      :temps_de_rappel => _('Response time'),
      :temps_de_contournement => _('Workaround time'),
      :temps_de_correction => _('Correction time')
    }
  end

end
