class ReportingController < ApplicationController
  require 'digest/sha1'
  model   :identifiant
  layout  'standard-layout'

  @@titres = { 
    :repartition => 'Répartition des demandes reçues',
    :repartition_cumulee => 'Répartition des demandes reçues',
    :severite => 'Sévérité des demandes reçues',
    :severite_cumulee => 'Sévérité des demandes reçues',
    :resolution => 'Résolution des demandes reçues',
    :resolution_cumulee => 'Résolution des demandes reçues',
    :evolution => 'Evolution des sollicitations distinctes',
    :top5_demandes => 'Top 5 des demandes les plus discutées',
    :top5_logiciels => 'Top 5 des logiciels les plus défectueux',
    :temps_rappel => 'Evolution du temps de prise en compte',
    :temps_contournement => 'Evolution du temps de contournement',
    :temps_correction => 'Evolution du temps de correction'
    }

  @@couleurs = [ nil, "#225588", "#228822", "#ee0000", "#bb88bb", "#be4800" ]
  # clair, foncé, ...
  @@couleurs_degradees = [nil, "#225588", "#336699", "#228822", "#339933", 
    "#ee0000", "#ff0000", "#bb88bb", "#cc99cc", "#be4800", "#cf5910" ]

  def index
    general
    render :action => 'configuration'
  end

  # utilisé avant l'affichage
  def configuration
    @contrats = (@beneficiaire ? @beneficiaire.client.contrats : 
                   Contrat.find(:all, Contrat::OPTIONS))
  end

  # deprecated
  # TODO : effacer
 #  def delai
#     report_delai

#     @clients.each do |c| 
#       write_graph(:"temps_rappel_#{c.id}", Gruff::Line)
#       write_graph(:"temps_contournement_#{c.id}", Gruff::Line) 
#       write_graph(:"temps_correction_#{c.id}", Gruff::Line)
#     end
#   end

  def general
    return redirect_to(:action => 'configuration') unless params[:reporting]
    init_class_var(params)
    return redirect_to(:action => 'configuration') unless 
      @report[:start_date] < @report[:end_date]
    init_data_general
    fill_data_general
    # TODO : trouver un bon moyen de faire un cache
    @data.each_pair do |nom, data| # each_key do |nom|
      #sha1 = Digest::SHA1.hexdigest("-#{qui}-#{nom}-")
      @path[nom] = "reporting/#{nom}.png"
      size = data.size 
      if (not data.empty? and data[0].to_s =~ /_(terminees|en_cours)/)
        @colors[nom] = @@couleurs_degradees[1..size]
      else
        @colors[nom] = @@couleurs[1..size]
      end
    end

    #on nettoie 
    # TODO retravailler le nettoyage
    # reporting = File.expand_path('public/reporting', RAILS_ROOT)
    # rmtree(reporting)
    # Dir.mkdir(reporting)

    # on remplit
#      write_graph(:repartition, Gruff::StackedBar)
#      write_graph(:severite, Gruff::StackedBar)
#      write_graph(:resolution, Gruff::StackedBar)
#      write_graph(:evolution, Gruff::Line)
#      write_graph(:annulation, Gruff::Line)

      
#     write_graph(:top5_demandes, Gruff::Pie)
#     write_graph(:top5_logiciels, Gruff::Pie)
    # on nettoie
    @first_col.each { |c| c.gsub!('\n','') }
  end

  private

  # initialise toutes les variables de classes nécessaire
  # path stocke les chemins d'accès, @données les données
  # @first_col contient la première colonne et @contrat le contrat
  # sélectionné
  def init_class_var(params)
    @contrat = Contrat.find(params[:reporting][:contrat_id])
    @data, @path, @report, @colors = {}, {}, {}, {}
    @titres = @@titres
    @report[:start_date] = [@contrat.ouverture.beginning_of_month, Time.now].min
    @report[:end_date] = [Time.now, @contrat.cloture.beginning_of_month].min
    @first_col = []
    current_month = @report[:start_date]
    end_date = @report[:end_date]
    while (current_month < end_date) do
      @first_col.push current_month.strftime('%b \n%Y')
      current_month = current_month.advance(:months => 1)
    end
    @labels = {}
    i = 0
    @first_col.each do |c|
      @labels[i] = c if ((i % 2) == 0)
      i += 1
    end
    middle_date = end_date.months_ago(params[:reporting][:period].to_i - 1)
    start_date = @report[:start_date]
    @report[:middle_date] = [ middle_date, start_date ].max.beginning_of_month
    @report[:middle_report] = ((end_date - @report[:middle_date]) / 1.month).round + 1
    @report[:total_report] = ((end_date - start_date) / 1.month).round + 1  
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
      [ [:bloquante_terminees], [:majeure_terminees], 
      [:mineure_terminees], [:sans_objet_terminees],
      [:bloquante_en_cours], [:majeure_en_cours], 
      [:mineure_en_cours], [:sans_objet_en_cours] ]
    @data[:resolution] = 
      [ [:corrigee], [:cloturee], [:annulee], [:en_cours] ]
    @data[:evolution] = 
      [ [:beneficiaires], [:logiciels], [:correctifs] ] # TODO : [:interactions]
    @data[:annulation] = 
      [ [:informations], [:anomalies], [:evolutions] ]

    # calcul des délais
#      @data[:temps_de_rappel] =
#       [ [:dans_les_delais_terminees], [:hors_delai_terminees],
#       [:dans_les_delais_en_cours], [:hors_delai_en_cours] ]
#      @data[:temps_de_contournement] =
#       [ [:dans_les_delais_terminees], [:hors_delai_terminees],
#       [:dans_les_delais_en_cours], [:hors_delai_en_cours] ]
#      @data[:temps_de_correction] =
#       [ [:dans_les_delais_terminees], [:hors_delai_terminees],
#       [:dans_les_delais_en_cours], [:hors_delai_en_cours] ]

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
      @data[key].each do |value|
        result = []
        result.push value[0]
        result.push value[start..-1].inject(0){|s, v| s + v}
        data[mykey].push result
      end
    end
    data
  end

  def fill_data_general
    start_date = @report[:start_date]
    end_date = @report[:end_date]

    liste = @contrat.client.beneficiaires.collect{|b| b.id} # .join(',')
    demandes = [ 'created_on BETWEEN ? AND ? AND demandes.beneficiaire_id IN (?)',
      nil, nil, liste ]  
    correctifs = [ 'correctifs.created_on BETWEEN ? AND ?', nil, nil ]  
    # (#{liste})" ]
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
#        compute_temps @data
        correctifs[1], correctifs[2] = infdate, supdate
        Correctif.with_scope({:find => {:conditions => correctifs }}) do
          compute_evolution @data[:evolution]
        end
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
  # Sort une moyenne de nos traitements des demandes
  # Sort le temps maximum de nos traitements des demandes
  def compute_temps(donnees)
    demandes = Demande.find_all
    rappels = donnees[:temps_de_rappel]
    contournements = donnees[:temps_de_contournement]
    corrections = donnees[:temps_de_correction]
    terminal = [6,7,8]
    support = @contrat.client.support
    amplitude = support.fermeture - support.ouverture
    demandes.each do |d|
      e = d.engagement(@contrat.id)
      etat = (terminal.include? d.statut_id ? 0 : 2) # +0 : terminées, +2 : en_cours
      
      rappel = d.temps_rappel
      fill_one_report(rappels, rappel, 1.hour, etat)

      contournement = distance_of_time_in_working_days(d.temps_contournement, amplitude)
      fill_one_report(contournements, contournement, e.contournement, etat)

      correction = distance_of_time_in_working_days(d.temps_correction, amplitude)
      fill_one_report(corrections, correction, e.correction, etat)
    end
#    size = demandes.size
#    fill_all_time_report(terminees, donnees, size, 0)
#    fill_all_time_report(encours, donnees, size, 2)
  end


  # Petit helper pour être dry, je sais pas trop comment l'appeler
  def fill_all_time_report(etat, donnees, size, i)
    fill_one_time_report(donnees[:temps_de_rappel], 
                         etat[:rappels], size, i)
    fill_one_time_report(donnees[:temps_de_contournement],
                         etat[:contournements], size, i)
    fill_one_time_report(donnees[:temps_de_correction],
                         etat[:corrections], size, i)
  end

  # Petit helper pour être dry, je sais pas trop comment l'appeler
  def fill_one_report(collection, value, max, etat)
    if value <= max
      collection[etat+0].last += 1
    else
      collection[etat+1].last += 1
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
      report.push [ :"#{nom}" ]
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
      report.push [ :"#{nom}" ]
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
    corrigee = { :conditions => [condition, 6] }
    cloturee = { :conditions => [condition, 7] }
    annulee = { :conditions => [condition, 8] }
    en_cours = { :conditions => 'statut_id NOT IN (6,7,8)' }

    report[0].push Demande.count(corrigee)
    report[1].push Demande.count(cloturee)
    report[2].push Demande.count(annulee)
    report[3].push Demande.count(en_cours)
  end


  ##
  # Calcule le nombre de beneficiaire, de logiciel et correctif distinct par mois
  def compute_evolution(report)
    # TODO : corriger ça, maintenant on a le contrat
    correctifs = 0
    if @beneficiaire
      ids = @beneficiaire.client.contrats.collect{|c| c.id}.join(',')
      conditions = [ "paquets.contrat_id IN (#{ids})" ]
      joins= 'INNER JOIN correctifs_paquets cp ON cp.correctif_id = correctifs.id ' +
        'INNER JOIN paquets ON cp.paquet_id = paquets.id '
      correctifs = Correctif.count(:conditions => conditions, :joins => joins)
    else
      correctifs = Correctif.count()
    end
    # TODO : distinct ?
    report[0].push Demande.count('beneficiaire_id', :distinct => true)
    report[1].push Demande.count('logiciel_id', :distinct => true)
    report[2].push correctifs
  end


  # Lance l'écriture des 3 graphes
  def write_graph(nom, graph)
    __write_graph(nom, graph)
    middle = :"#{nom}_middle"
    __write_graph(middle, Gruff::Pie, "Répartition sur #{@report[:middle_report]} mois") if @data[middle]
    total = :"#{nom}_total"
    __write_graph(total, Gruff::Pie, "Répartition sur #{@report[:total_report]} mois") if @data[total]
  end
  # Ecrit le graphe en utilisant les données indexées par 'nom' dans @données
  # grâce au chemin d'accès spécifié dans @path[nom]
  # graph sert à spécifier le type de graphe attendu
  def __write_graph(nom, graph, title = 'Récapitulatif')
    return unless @data[nom]
    g = graph.new(450)

    if title; g.title = title; else g.hide_title = true; end
    g.theme_37signals
    g.colors = @colors[nom]
    g.sort = false
    # g.font =  File.expand_path('public/font/VeraBd.ttf', RAILS_ROOT)
    data = @data[nom].sort{|x,y| x[0].to_s <=> y[0].to_s}
    data.each {|value| g.data(value[0], value[1..-1]) }
    g.labels = @labels
    g.hide_dots = true if g.respond_to? :hide_dots
    g.hide_legend = true
    # TODO : mettre ca dans les metadatas
    g.no_data_message = 'Aucune donnée\n n\'est disponible'

    # this writes the file to the hard drive for caching
    g.write "public/images/#{@path[nom]}"
  end

  # TODO : mettre ça dans le modèle Demande
  # Calcule en JO le temps écoulé 
  def distance_of_time_in_working_days(distance_in_seconds, period_in_hour)
    distance_in_minutes = ((distance_in_seconds.abs)/60.0)
    jo = period_in_hour * 60.0
    distance_in_minutes.to_f / jo.to_f 
  end


  def scope_beneficiaire
    if @contrat
      liste = @contrat.client.beneficiaires.collect{|b| b.id} # .join(',')
      conditions = [ 'demandes.beneficiaire_id IN ?', liste ]
# (#{liste})" ]
      Demande.with_scope({ :find => { :conditions => conditions } }) { 
        yield }
    else
      yield
    end
  end

  # TODO : on efface cette fonction ?
  def report_mensuel(start_date, end_date = Time.now)
    init_general unless @data

    @dates = {}
    i = 0
    until (start_date > end_date) do 
      infdate = "'" + start_date.strftime('%y-%m') + "-01'"
      supdate = "'" + (start_date.advance(:months => 1)).strftime('%y-%m') + "-01'"
      
      @conditions = [ "created_on BETWEEN #{infdate} AND #{supdate}" ]
      date = start_date.strftime('%b')
      @dates[i] = date
      i += 1
      Demande.with_scope({ :find => { :conditions => @conditions } }) do
        compute_repartition @data[:repartition]
        compute_severite @data[:severite]     
        compute_resolution @data[:resolution]
        compute_evolution @data[:evolution]
      end
      start_date = start_date.advance(:months => 1)
    end

    end_date = start_date
    start_date = Time.mktime(@annee) 
    infdate = "'" + start_date.strftime('%y-%m') + "-01'"
    supdate = "'" + end_date.strftime('%y-%m') + "-01'"
    @conditions = [ "created_on BETWEEN #{infdate} AND #{supdate}" ]
    # @demande_ids = Demande.find(:all, :select => 'demandes.id').join(',')
    Demande.with_scope({ :find => { :conditions => @conditions } }) do
      compute_repartition @data[:repartition_cumulee]
      compute_severite @data[:severite_cumulee]
      compute_resolution @data[:resolution_cumulee]

      compute_top5_logiciels @data[:top5_logiciels]
      Commentaire.with_scope({ :find => { :conditions => @conditions } }) do
        compute_top5_demandes @data[:top5_demandes]
      end
    end
  end

end
