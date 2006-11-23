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
    jour = Date.today.strftime "%j%Y"
    qui = (@beneficiaire ? @beneficiaire.client : 'tous')
    @path = {}

    init_report
    @historiques.each_key do |nom|
      sha1 = Digest::SHA1.hexdigest("-#{jour}-#{qui}-#{nom}-") 
      @path[nom] = "/reporting/#{sha1}.png"
    end

    @repartitions.each_key do |nom|
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
    self.write_graph(@historiques, :repartition, Gruff::StackedBar)
    self.write_graph(@historiques, :severite, Gruff::StackedBar)
    self.write_graph(@historiques, :resolution, Gruff::StackedBar)
    self.write_graph(@historiques, :evolution, Gruff::Line)

    self.write_graph(@repartitions, :repartition_cumulee, Gruff::Pie)
    self.write_graph(@repartitions, :severite_cumulee, Gruff::Pie)
    self.write_graph(@repartitions, :resolution_cumulee, Gruff::Pie)
    
  end

  private
  def init_report
    @historiques = {}
    @repartitions = {}

    @historiques[:repartition]  = 
      [ [:anomalies], [:informations], [:evolutions] ]
    @historiques[:severite] = 
      [ [:bloquante], [:majeure], [:mineure], [:sansobjet] ]
    @historiques[:resolution] = 
      [ [:cloturee], [:annulee], [:encours] ]
    @historiques[:evolution] = 
      [ [:beneficiaires], [:logiciels] ] # , [:correctifs]

    @repartitions[:repartition_cumulee] = 
      [ [:anomalies], [:informations], [:evolutions] ]
    # @historiques[:repartition].dup
    @repartitions[:severite_cumulee] = 
      [ [:bloquante], [:majeure], [:mineure], [:sansobjet] ]
    @repartitions[:resolution_cumulee] = 
      [ [:cloturee], [:annulee], [:encours] ]  
  end

  def report
    init_report unless @historiques
    # @client = Client.find(params[:id])
    # @demandes = Demande.find(:all)
    @severite, @cumul, @resolution = {}, [], [], []
    start = Time.mktime("2006") 

    @dates = {}
    i = 0
    until (start > Time.mktime("2006", 12)) do 
      infdate = "'" + start.strftime('%y-%m') + "-01'"
      supdate = "'" + (start.advance(:months => 1)).strftime('%y-%m') + "-01'"
      
      conditions = [ "created_on BETWEEN #{infdate} AND #{supdate}" ]
      date = start.strftime('%b')
      @dates[i] = date
      i += 1
      Demande.with_scope({ :find => { :conditions => conditions } }) do
        demandes = Demande.count
        report_repartition @historiques[:repartition]
        report_severite @historiques[:severite]     
        report_resolution @historiques[:resolution]
        report_evolution @historiques[:evolution]
      end
      start = start.advance(:months => 1)
    end

    report_repartition @repartitions[:repartition_cumulee]
    report_severite @repartitions[:severite_cumulee]
    report_resolution @repartitions[:resolution_cumulee]

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
    g.labels = @dates

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
