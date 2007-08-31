#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
#
class ReportingController < ApplicationController
  helper :demandes, :export
  include ComexReporting

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
    @contrats = (@beneficiaire ? @beneficiaire.client.contrats :
                 Contrat.find(:all, Contrat::OPTIONS))
  end
  def new
    redirect_to :action => 'index', :controller => :demandes
  end

  def comex
    #_titles()
  end

  def comex_resultat
    #_titles()
    control = params[:control]
    results = params[:results]
    cns = params[:cns]
    comex = params[:reporting]

    clients = '(' << params[:clients].join(',') << ')'
    @date, scope = {}, {}
    if cns
      @cns= cns
      scope= { :conditions => "client_id IN #{clients}"} unless clients.include?('all')
      Contrat.with_scope(:find => scope) {
        cns_correction()
      }
      return
    end
     (redirect_to comex_reporting_path and return) unless results
    if results[:first_day].blank? or results[:end_day].blank?

      if results[:week_num].blank?
        flash[:notice]= _('You must choose a period for the report')
        redirect_to comex_reporting_path and return
      else
        @date[:first_day] = Time.now.beginning_of_year +
         (results[:week_num].to_i-1).week
        @date[:end_day] = @date[:first_day] + 6.days
      end
    else
      @date[:first_day] = results[:first_day].to_time.beginning_of_day
      @date[:end_day] = results[:end_day].to_time.beginning_of_day +
      1.day - 1.second
    end
    # user 'n developer sanity check
    if @date[:first_day] > @date[:end_day]
      flash[:notice]= _('The first day must precede the last day')
      redirect_to comex_reporting_path and return
    end
    if comex
      scope= { :conditions => "id IN #{clients}"} unless clients.include?('all')
      Client.with_scope(:find => scope) {
        init_comex_report()
      }
      @clients.each do |client|
        compute_comex_report(client)
      end
    end
    flash[:clients]= @clients
    flash[:requests]= @requests
    flash[:total]= @total
end


  def general
    _titles()
    redirect_to configuration_reporting_path and return unless 
      params[:reporting]

    init_class_var(params)
    redirect_to configuration_reporting_path and return unless
      @contrat and (@report[:start_date] < @report[:end_date])
    init_data_general
    fill_data_general

    # TODO : trouver un bon moyen de faire un cache
    @data.each_pair do |nom, data| # each_key do |nom|
      #sha1 = Digest::SHA1.hexdigest("-#{qui}-#{nom}-")
      @path[nom] = "reporting/#{nom}.png"
      size = data.size
      if (not data.empty? and data[0].to_s =~ /_(terminees|en_cours)/)
        # cas d'une légende à deux colonnes : degradé obligatoire
        if nom.to_s =~ /^severite/
          @colors[nom] = @@couleurs_degradees[1..size]
        elsif nom.to_s =~ /^repartition/
          @colors[nom] = @@couleurs_types_degradees[1..size]
        else
          @colors[nom] = @@couleurs_degradees[1..size]
        end
      else
        # cas d'une légende à une colonne : pas de degradé
        if nom.to_s =~ /^temps/
          @colors[nom] = @@couleurs_delais[1..size]
        elsif nom.to_s =~ /^annulation/
          @colors[nom] = @@couleurs_types[1..size]
        else
          @colors[nom] = @@couleurs[1..size]
        end
      end
    end


    #on nettoie
    # TODO retravailler le nettoyage
    # reporting = File.expand_path('public/reporting', RAILS_ROOT)
    # rmtree(reporting)
    # Dir.mkdir(reporting)

    # on remplit
    je_veux_mettre_a_jour_les_graphes = true
    if (je_veux_mettre_a_jour_les_graphes)
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

  def flux
    #cas spécial : consultation directe
    options = { :per_page => 10, :order => 'created_on DESC',
      :select => Demande::SELECT_LIST,
      :joins => Demande::JOINS_LIST }
    @demande_pages, @demandes = paginate :demandes, options
  end


  private

  # initialise toutes les variables de classes nécessaire
  # path stocke les chemins d'accès, @données les données
  # @first_col contient la première colonne et @contrat le contrat
  # sélectionné
  def init_class_var(params)
    period =  params[:reporting][:period].to_i
    return unless period > 0
    @contrat = Contrat.find(params[:reporting][:contrat_id].to_i)
    @data, @path, @report, @colors = {}, {}, {}, {}
    @titles = @@titles
    @report[:start_date] = [@contrat.ouverture.beginning_of_month, Time.now].min
    @report[:end_date] = [calendar2time(params[:end_date]),
    @contrat.cloture.beginning_of_month].min
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
    if period == 1
      middle_date = end_date.beginning_of_month
    else
      middle_date = end_date.months_ago(period - 1)
    end
    start_date = @report[:start_date]
    if (middle_date > start_date and middle_date < end_date)
      @report[:middle_date] = [ middle_date, start_date ].max.beginning_of_month
      @report[:middle_report] = ((end_date.beginning_of_month - @report[:middle_date]) / 1.month).round + 1
      @report[:total_report] = ((end_date.beginning_of_month - start_date.beginning_of_month) / 1.month).round + 1
    else
      flash.now[:warn] = _('incorrect parameters')
      # condition de sortie
      @contrat = nil
    end
  rescue
    flash.now[:warn] = _('incorrect parameters')
    @contrat = nil

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


    # Camemberts nommé dynamiquement
    #    @data[:top5_logiciels] = [ ]
    #    @data[:top5_demandes] = [ ]
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

    liste = @contrat.client.beneficiaires.collect{|b| b.id} # .join(',')
    demandes = [ 'demandes.created_on BETWEEN ? AND ? AND demandes.beneficiaire_id IN (?)',
    nil, nil, liste ]
    contributions = [ 'contributions.created_on BETWEEN ? AND ?', nil, nil ]
    # (#{liste})" ]

    # TODO : provient du scope de appication.rb
    # TODO : Le scope des contribs devrait plutot porter
    # sur les demandes qui ont des contribs, non.
    cpaquets = ['paquets.contrat_id = ?', @contrat.id ]
    scontributions = {:find => {:conditions => cpaquets, :include => [:paquets]}}
    Contribution.with_scope(scontributions) {
      until (start_date > end_date) do
        infdate = "#{start_date.strftime('%y-%m')}-01"
        start_date = start_date.advance(:months => 1)
        supdate = "#{start_date.strftime('%y-%m')}-01"

        demandes[1], demandes[2] = infdate, supdate
        Demande.with_scope({ :find => { :conditions => demandes } }) do
          compute_repartition @data[:repartition]
          compute_severite @data[:severite]
          compute_resolution @data[:resolution]
          compute_annulation @data[:annulation]
          compute_temps @data
          contributions[1], contributions[2] = infdate, supdate
          Contribution.with_scope({:find => {:conditions => contributions }}) do
            compute_evolution @data[:evolution]
          end
        end
      end
    }
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
  def compute_temps(donnees)
    demandes = Demande.find(:all)
    rappels = donnees[:temps_de_rappel]
    contournements = donnees[:temps_de_contournement]
    corrections = donnees[:temps_de_correction]
    last_index = rappels[0].size
    2.times {|i|
      rappels[i].push 0.0
      contournements[i].push 0.0
      corrections[i].push 0.0
    }

    terminal = [6,7,8]
    contrat_id = @contrat.id
    support = @contrat.client.support
    amplitude = support.fermeture - support.ouverture
    demandes.each do |d|
      e = d.engagement(contrat_id)
      next unless e

      rappel = d.temps_rappel()
      fill_one_report(rappels, rappel, 1.hour, last_index)

      contournement = d.distance_of_time_in_working_days(d.temps_contournement, amplitude)
      fill_one_report(contournements, contournement, e.contournement, last_index)

      correction = d.distance_of_time_in_working_days(d.temps_correction, amplitude)
      fill_one_report(corrections, correction, e.correction, last_index)
    end

    size = demandes.size
    if size > 0
      size = size.to_f
      2.times {|i|
        rappels[i][last_index] = (rappels[i][last_index].to_f / size) * 100
        contournements[i][last_index] = (contournements[i][last_index].to_f / size) * 100
        corrections[i][last_index] = (corrections[i][last_index].to_f / size) * 100
      }
    end
  end

  # Petit helper pour être dry, je sais pas trop comment l'appeler
  def fill_one_report(collection, value, max, last)
    if ((value <= max) || (max == -1))
      collection[0][last] += 1
    else
      collection[1][last] += 1
    end
  end


  ##
  # TODO : le faire marcher si y a moins de 5 logiciels
  # sort les 5 logiciels qui ont eu le plus de demandes
  def compute_top5_logiciels(report)
    logiciels = Demande.count(:group => "logiciel_id")
    logiciels = logiciels.sort {|a,b| a[1]<=>b[1]}
    5.times do |i|
      values = logiciels.pop
      nom = Logiciel.find(values[0]).nom
      report.push [ nom.intern ]
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
      nom = values[0].to_s # "##{values[0]} (#{values[1]})"
      report.push [ nom.intern ]
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

    Demande.with_scope({ :find => { :conditions => Demande::TERMINEES } }) do
      report[0].push Demande.count(informations)
      report[1].push Demande.count(anomalies)
      report[2].push Demande.count(evolutions)
    end

    Demande.with_scope({ :find => { :conditions => Demande::EN_COURS } }) do
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

    Demande.with_scope({ :find => { :conditions => Demande::TERMINEES } }) do
      4.times do |t|
        report[t].push Demande.count(severites[t])
      end
    end
    Demande.with_scope({ :find => { :conditions => Demande::EN_COURS } }) do
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
  # Calcule le nombre de beneficiaire, de logiciel et contribution distinct par mois
  def compute_evolution(report)
    # TODO : corriger ça, maintenant on a le contrat
    contributions = 0
    if @beneficiaire
      ids = @beneficiaire.client.contrats.collect{|c| c.id}.join(',')
      conditions = [ "paquets.contrat_id IN (#{ids})" ]
      joins= 'INNER JOIN contributions_paquets cp ON cp.contribution_id = contributions.id ' +
        'INNER JOIN paquets ON cp.paquet_id = paquets.id '
      contributions = Contribution.count(:conditions => conditions, :joins => joins)
    else
      contributions = Contribution.count()
    end
    # TODO : distinct ?
    report[0].push Demande.count('beneficiaire_id', :distinct => true)
    report[1].push Demande.count('logiciel_id', :distinct => true)
    report[2].push contributions
  end


  # Lance l'écriture des _3_ graphes
  def write3graph(nom, graph)
    __write_graph(nom, graph)
    middle = :"#{nom}_middle"
    __write_graph(middle, Gruff::Pie, _("Distributed on ") + "#{@report[:middle_report]}" + _(" months")) if @data[middle]
    total = :"#{nom}_total"
    __write_graph(total, Gruff::Pie, _("Distributed on ") + "#{@report[:total_report]}" + _(" months")) if @data[total]
  end
  # Ecrit le graphe en utilisant les données indexées par 'nom' dans @données
  # grâce au chemin d'accès spécifié dans @path[nom]
  # graph sert à spécifier le type de graphe attendu
  def __write_graph(nom, graph, title = _('Summary'))
    return unless @data[nom]
    g = graph.new(450)

    # Trop confus pour l'utilisateur et plus de place pour le graphe
    # if title; g.title = title; else g.hide_title = true; end
    g.hide_title = true
    g.theme = { #    g.theme_37signals légèrement modifié
      :colors => @colors[nom],
      :marker_color => 'black',
      :font_color => 'black',
      :background_colors => ['white', 'white']
    }
    g.sort = false

    data = @data[nom].sort{|x,y| x[0].to_s <=> y[0].to_s}
    data.each {|value| g.data(value[0], value[1..-1]) }
    g.labels = @labels
    g.hide_dots = true if g.respond_to? :hide_dots
    g.hide_legend = true
    # TODO : mettre ca dans les metadatas
    g.no_data_message = _("No data \navailable")

    # this writes the file to the hard drive for caching
    g.write "#{RAILS_ROOT}/public/images/#{@path[nom]}"
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


  # TODO : L'enlever de reporting
  # il est dans models/demandes
  # Calcule en JO le temps écoulé
"""  def distance_of_time_in_working_days(distance_in_seconds, period_in_hour)
    distance_in_minutes = ((distance_in_seconds.abs)/60.0)
    jo = period_in_hour * 60.0
    distance_in_minutes.to_f / jo.to_f
  end
	"""
end
