class ReportingController < ApplicationController
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
    :temps_moyen => 'Moyenne du temps de traitement',
    :temps_maximum => 'Temps de traitement maximum constaté'
    }

  def index
    general
    render :action => 'general'
  end

  def delai
    init_action
    jour = Date.today.strftime "%j" + @annee
    qui = (@beneficiaire ? @beneficiaire.client : 'tous')
    # TODO : init_delai
    @donnees.each_key do |nom|
      sha1 = Digest::SHA1.hexdigest("-#{jour}-#{qui}-#{nom}-") 
      @path[nom] = "/reporting/#{sha1}.png"
    end

    if @beneficiaire
      @contrats = @beneficiaire.client.contrats
    else
      @contrats = Contrat.find(:all)
    end

    write_graph(:temps_moyen, Gruff::Pie)
    write_graph(:temps_maximum, Gruff::Pie)
  end

  def general
    init_action(params)
    jour = Date.today.strftime "%j" + @annee
    qui = (@beneficiaire ? @beneficiaire.client : 'tous')
    init_general
    @donnees.each_key do |nom|
      sha1 = Digest::SHA1.hexdigest("-#{jour}-#{qui}-#{nom}-") 
      @path[nom] = "/reporting/#{sha1}.png"
    end


    #un peu de cache homemade : une génération par jour
    report_general
    # return if File.exist?("public/#{@path[:repartition]}")

    #on nettoie 
    reporting = File.expand_path('public/reporting', RAILS_ROOT)
    rmtree(reporting)
    Dir.mkdir(reporting)

    #on remplit
    write_graph(:top5_demandes, Gruff::Pie)
    write_graph(:top5_logiciels, Gruff::Pie)
    write_graph(:repartition, Gruff::StackedBar)
    write_graph(:severite, Gruff::StackedBar)
    write_graph(:resolution, Gruff::StackedBar)
    write_graph(:evolution, Gruff::Line)
    write_graph(:repartition_cumulee, Gruff::Pie)
    write_graph(:severite_cumulee, Gruff::Pie)
    write_graph(:resolution_cumulee, Gruff::Pie)
    
  end

  private
  def init_action(params)
    require 'digest/sha1'
    @titres = @@titres
    @annee = params[:id] || Time.now.year.to_s
    @path = {}
    @first_col = Date::MONTHNAMES[1..-1] + [ "<b>#{@annee}</b>" ]
    @donnees = {}
  end

  def init_general
    # Répartions par mois (StackedBar)
    @donnees[:repartition]  = 
      [ [:anomalies], [:informations], [:evolutions] ]
    @donnees[:severite] = 
      [ [:bloquante], [:majeure], [:mineure], [:sansobjet] ]
    @donnees[:resolution] = 
      [ [:cloturee], [:annulee], [:encours] ]
    @donnees[:evolution] = 
      [ [:beneficiaires], [:logiciels], [:correctifs] ] # TODO : [:correctifs], [:interactions]

    # Camemberts nommé dynamiquement
    @donnees[:top5_logiciels] = [ ]
    @donnees[:top5_demandes] = [ ] 

    # Camemberts statiques
    @donnees[:repartition_cumulee] = 
      [ [:anomalies], [:informations], [:evolutions] ]
    @donnees[:severite_cumulee] = 
      [ [:bloquante], [:majeure], [:mineure], [:sansobjet] ]
    @donnees[:resolution_cumulee] = 
      [ [:cloturee], [:annulee], [:encours] ]
  end

  def init_delai
    # SideBar sur l'ensemble
    @contrats.each do |c|
      @donnees[:"temps_moyen_#{c.id}"] =
        [ [:rappel], [:contournement], [:correction] ]
      @donnees[:"temps_max_#{c.id}"] =
        [ [:rappel], [:contournement], [:correction] ]
    end
  end


  def report_delai
    start_date = Time.mktime(@annee)
    end_date = Time.mktime(@annee, 12)

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
        report_temps @donnees[:repartition]
      end
      start_date = start_date.advance(:months => 1)
    end

    
  end

  def report_general
    init_general unless @donnees
    start_date = Time.mktime(@annee)
    end_date = Time.mktime(@annee, 12)

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
        report_repartition @donnees[:repartition]
        report_severite @donnees[:severite]     
        report_resolution @donnees[:resolution]
        report_evolution @donnees[:evolution]
      end
      start_date = start_date.advance(:months => 1)
    end

    start_date = Time.mktime(@annee) 
    infdate = "'" + start_date.strftime('%y-%m') + "-01'"
    supdate = "'" + end_date.strftime('%y-%m') + "-01'"
    @conditions = [ "created_on BETWEEN #{infdate} AND #{supdate}" ]
    @demande_ids = Demande.find(:all, :select => 'demandes.id').join(',')
    Demande.with_scope({ :find => { :conditions => @conditions } }) do
      report_repartition @donnees[:repartition_cumulee]
      report_severite @donnees[:severite_cumulee]
      report_resolution @donnees[:resolution_cumulee]

      report_top5_logiciels @donnees[:top5_logiciels]
      Commentaire.with_scope({ :find => { :conditions => @conditions } }) do
        report_top5_demandes @donnees[:top5_demandes]
      end
    end
  end


  ##
  # Sort une moyenne de nos traitements des demandes
  # Sort le temps maximum de nos traitements des demandes
  def report_temps(donnees)
    demandes = Demande.find(:all)

    temps_rappels = []
    demandes.each do |d|
      temps_rappels.push d.temps_rappel / 60# contrat.id
    end
    report = donnees[:temps_moyen]
    report[0].push(avg(temps_rappels).round)
    report[1].push demandes.size
    report[2].push 2

    report = donnees[:temps_maximum]
    report[0].push(temps_rappels.max.round)
    report[1].push demandes.size
    report[2].push 2

  end

  ##
  # Sort notre temps maximum de traitement d'une demande
  def report_temps_maximum(report)
    @temps_rappels ||= init_temps_rappels
    report[0].push 10
    report[1].push 15
    report[2].push 30

  end

  ##
  # sort les 5 logiciels qui ont eu le plus de demandes
  def report_top5_logiciels(report)
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
  # Sort les 5 demandes les plus commentées de l'année
  def report_top5_demandes(report)
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
  # Compte les demandes selon leur nature
  def report_repartition(report)
    anomalies = { :conditions => "typedemande_id = 1" }
    informations = { :conditions => "typedemande_id = 2" }
    evolutions = { :conditions => "typedemande_id = 5" }

    report[0].push Demande.count(anomalies)
    report[1].push Demande.count(informations)
    report[2].push Demande.count(evolutions)
  end

  ##
  # Compte les demandes par sévérités
  def report_severite(report)
    severites = []
    (1..4).each do |i|
      severites.concat [ { :conditions => "severite_id = #{i}" } ]
    end

    4.times do |t|
      report[t].push Demande.count(severites[t])
    end
  end

  ##
  # Compte le nombre de demande Annulée, Cloturée ou en cours de traitement
  def report_resolution(report)
    cloturee = { :conditions => "statut_id = 7" }
    annulee = { :conditions => "statut_id = 8" }
    encours = { :conditions => "statut_id NOT IN (7,8)" }

    report[0].push Demande.count(cloturee)
    report[1].push Demande.count(annulee)
    report[2].push Demande.count(encours)
  end


  ##
  # Calcule le nombre de beneficiaire, de logiciel et correctif distinct par mois
  def report_evolution(report)
    correctifs = 0
    Correctif.with_scope({ :find => { :conditions => @conditions } }) do
      if @beneficiaire
        ids = @beneficiaire.client.contrats.collect{|c| c.id}.join(',')
        conditions = [ "paquets.contrat_id IN (#{ids})" ]
        joins= 'INNER JOIN correctifs_paquets cp ON cp.correctif_id = correctifs.id ' +
          'INNER JOIN paquets ON cp.paquet_id = paquet.id '
        correctifs = Correctif.count(:conditions => conditions, :joins => joins)
      else
        correctifs = Correctif.count()
      end
    end

    report[0].push Demande.count('beneficiaire_id', :distinct => true)
    report[1].push Demande.count('logiciel_id', :distinct => true)
    report[2].push correctifs
  end


  def write_graph(nom, graph)
    g = graph.new
    g.sort = false

    g.title = @@titres[nom]
    g.theme_37signals
    # g.font =  File.expand_path('public/font/VeraBd.ttf', RAILS_ROOT)
    @donnees[nom].each {|value| g.data(value[0], value[1..-1]) }
    g.labels =  Date::ABBR_MONTHS_LSTM
    g.hide_dots = true if g.respond_to? :hide_dots
    g.no_data_message = 'Aucune donnée\n disponible'

    # this writes the file to the hard drive for caching
    g.write "public/#{@path[nom]}"
  end


  def scope_beneficiaire
    if @beneficiaire
      liste = @beneficiaire.client.beneficiaires.collect{|b| b.id}.join(',')
      conditions = [ "demandes.beneficiaire_id IN (#{liste})" ]
      Demande.with_scope({ :find => { 
                             :conditions => conditions
                          }
                        }) { yield }
    else
      yield
    end
  end

end
