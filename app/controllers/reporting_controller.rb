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
    }

  def index
    general
    render :action => 'general'
  end

  def general
    require 'digest/sha1'
    @titres = @@titres
    @annee = params[:id] || Time.now.year.to_s
    jour = Date.today.strftime "%j" + @annee
    qui = (@beneficiaire ? @beneficiaire.client : 'tous')
    @path = {}
    @first_col = Date::MONTHNAMES[1..-1] + [ "<b>#{@annee}</b>" ]

    init_report
    @donnees.each_key do |nom|
      sha1 = Digest::SHA1.hexdigest("-#{jour}-#{qui}-#{nom}-") 
      @path[nom] = "/reporting/#{sha1}.png"
    end


    #un peu de cache homemade : une génération par jour
    report 
    # return if File.exist?("public/#{@path[:repartition]}")

    #on nettoie 
    reporting = File.expand_path('public/reporting', RAILS_ROOT)
    rmtree(reporting)
    Dir.mkdir(reporting)

    #on remplit
#      write_graph(@donnees, :repartition, Gruff::StackedBar)
#      write_graph(@donnees, :severite, Gruff::StackedBar)
#      write_graph(@donnees, :resolution, Gruff::StackedBar)
    write_graph(@donnees, :evolution, Gruff::Line)

#      write_graph(@donnees, :repartition_cumulee, Gruff::Pie)
#      write_graph(@donnees, :severite_cumulee, Gruff::Pie)
#      write_graph(@donnees, :resolution_cumulee, Gruff::Pie)
    
  end

  private
  def init_report
    @donnees = {}

    @donnees[:repartition]  = 
      [ [:anomalies], [:informations], [:evolutions] ]
    @donnees[:severite] = 
      [ [:bloquante], [:majeure], [:mineure], [:sansobjet] ]
    @donnees[:resolution] = 
      [ [:cloturee], [:annulee], [:encours] ]
    @donnees[:evolution] = 
      [ [:beneficiaires], [:logiciels] ] # TODO : [:correctifs], [:interactions]

    @donnees[:repartition_cumulee] = 
      [ [:anomalies], [:informations], [:evolutions] ]
    @donnees[:severite_cumulee] = 
      [ [:bloquante], [:majeure], [:mineure], [:sansobjet] ]
    @donnees[:resolution_cumulee] = 
      [ [:cloturee], [:annulee], [:encours] ]
  end

  def report
    init_report unless @donnees
    start_date = Time.mktime(@annee)
    end_date = Time.mktime(@annee, 12)

    @dates = {}
    i = 0
    until (start_date > end_date) do 
      infdate = "'" + start_date.strftime('%y-%m') + "-01'"
      supdate = "'" + (start_date.advance(:months => 1)).strftime('%y-%m') + "-01'"
      
      conditions = [ "created_on BETWEEN #{infdate} AND #{supdate}" ]
      date = start_date.strftime('%b')
      @dates[i] = date
      i += 1
      Demande.with_scope({ :find => { :conditions => conditions } }) do
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
    conditions = [ "created_on BETWEEN #{infdate} AND #{supdate}" ]
    Demande.with_scope({ :find => { :conditions => conditions } }) do
      report_repartition @donnees[:repartition_cumulee]
      report_severite @donnees[:severite_cumulee]
      report_resolution @donnees[:resolution_cumulee]
    end
  end



  def report_repartition(report)
    anomalies = { :conditions => "typedemande_id = 1" }
    informations = { :conditions => "typedemande_id = 2" }
    evolutions = { :conditions => "typedemande_id = 5" }

    report[0].push Demande.count(anomalies)
    report[1].push Demande.count(informations)
    report[2].push Demande.count(evolutions)
  end

  def report_severite(report)
    severites = []
    (1..4).each do |i|
      severites.concat [ { :conditions => "severite_id = #{i}" } ]
    end

    4.times do |t|
      report[t].push Demande.count(severites[t])
    end
  end

  def report_resolution(report)
    cloturee = { :conditions => "statut_id = 7" }
    annulee = { :conditions => "statut_id = 8" }
    encours = { :conditions => "statut_id NOT IN (7,8)" }

    report[0].push Demande.count(cloturee)
    report[1].push Demande.count(annulee)
    report[2].push Demande.count(encours)
  end

  def report_evolution(report)
    beneficiaires = { }
    logiciels = {}
#    correctifs = {}

    report[0].push Demande.count('beneficiaire_id', :distinct => true)
    report[1].push Demande.count('logiciel_id', :distinct => true)
#    report[2].push Demande.count(encours)   
  end


  def write_graph(elements, nom, graph)
    donnees = elements[nom]
    g = graph.new
    g.sort = false

    g.title = @@titres[nom]
    g.theme_37signals
    # g.font =  File.expand_path('public/font/VeraBd.ttf', RAILS_ROOT)
    donnees.each {|value| g.data(value[0], value[1..-1]) }
    g.labels =  Date::ABBR_MONTHS_LSTM
    g.hide_dots = true
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
