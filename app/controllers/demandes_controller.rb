#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class DemandesController < ApplicationController
  before_filter :verifie, 
  :only => [ :comment, :edit, :update, :destroy, :changer_statut ]

  helper :correctifs

  @@titres = { 
    :repartition => 'Répartition des demandes reçues',
    :repartition_cumulee => 'Répartition des demandes reçues',
    :severite => 'Sévérité des demandes reçues',
    :severite_cumulee => 'Sévérité des demandes reçues',
    :resolution => 'Résolution des demandes reçues',
    :resolution_cumulee => 'Résolution des demandes reçues',
    }


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

  def test
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

  # verifie :
  # - s'il il y a un demande_id en paramètre (sinon :  retour à la liste)
  # - si une demande ayant cet id existe (sinon : erreur > rescue > retour à la liste)
  # - dans le cas d'un bénéficiaire, s'il est bien beneficiaire de cette demande (sinon : retour à la liste)
  def verifie
    if !params[:id]
      flash[:warn] = "Veuillez préciser l'identifiant de la demande à consulter." 
      redirect_to :action => 'list' and return false
    end
    demande = Demande.find(params[:id])
    true
  rescue  ActiveRecord::RecordNotFound
    flash[:warn] = "Acune demande ne correspond à l'identifiant " + params[:id] + "."
    list
    redirect_to :action => 'list' and return false
  end

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }


  def raz_recherche
    @session[:filtres] = {}
    redirect_to :back
  end

  def list
    return unless @session[:user]
    #cas spécial : consultation directe
    redirect_to :action => :comment, :id => params['numero'] if @params['numero'] 

    #init des variables utilisées dans la vue
    @clients = Client.find_all 
    #Identifiant.find_all where ingenieur
    joins = "INNER JOIN ingenieurs ON ingenieurs.identifiant_id = identifiants.id"
    @identifiants_ingenieurs = Identifiant.find(:all, :joins => joins)
    @count = Demande.count

    # récupération des paramètres, que l'on refile à la vue
    case @params['filter']
      when 'true' 
      @session[:filtres][:liste_globale] = true
      when 'false'
      @session[:filtres][:liste_globale] = false
      else
    end
    @session[:filtres][:recherche_demande] = @params['demande'] if @params['demande']
    if @params['client']
      if params['client'] != ''
        @session[:filtres][:client_id] = @params['client'].to_i
      else
        @session[:filtres][:client_id] = nil
      end
    end
    if @params['ingenieur']
      if params['ingenieur'] != ''
        @session[:filtres][:ingenieur_id] = Ingenieur.find(@params['ingenieur'].to_i).id
      else
        @session[:filtres][:ingenieur_id] = nil
      end
    end
    
    filtres, user = @session[:filtres], @session[:user]
    # défaut
    query, params = [ "statut_id <> ? " ], [ 0 ] 
    if filtres[:liste_globale] == false or 
        (user.affichage_personnel and filtres[:liste_globale] != true)
      query.push "statut_id NOT IN (?,?)" 
      params.concat [ 7, 8 ] 
    end

    if filtres[:client_id]
      ids = Beneficiaire.find_all_by_client_id(filtres[:client_id]).collect{|b| [ b.id ]}
      query.push " demandes.beneficiaire_id IN (#{ids.join(',')})" unless ids.empty?
    end

    if filtres[:recherche_demande]
      search =  "%#{filtres[:recherche_demande]}%" 
      query.push " (resume LIKE ? OR description LIKE ?) "
      params.concat [ search, search ]
    end

    if filtres[:ingenieur_id] or 
        (filtres[:liste_globale] != true and 
           user.affichage_personnel and 
           @ingenieur)
      query.push " (demandes.ingenieur_id = ? OR demandes.ingenieur_id IS NULL) " 
      params.push filtres[:ingenieur_id] || @ingenieur.id 
    end

    if not @beneficiaire and not @ingenieur
      flash[:warn] = "Vous n'êtes pas identifié comme appartenant à un groupe.\
                        Veuillez nous contacter pour nous avertir de cet incident."
      @demandes = [] # renvoi un tableau vide
    end

    conditions = [ query.join(" AND ") ] + params
    @query = query.join(" AND ") + params.inspect
    @demande_pages, @demandes = paginate :demandes, :per_page => 15,
      :order => 'updated_on DESC', :conditions => conditions
  end


  def new
    @demande = Demande.new unless @demande
    common_form @beneficiaire

    # sans object par défaut 
    @demande.severite_id = 4
    # statut "prise en compte" si ingénieur, sinon : "enregistrée"
    @demande.statut_id = (@ingenieur ? 2 : 1)

    @demande.beneficiaire_id = @beneficiaire.id if @beneficiaire
  end

  def create
    @demande = Demande.new(params[:demande])
    @demande.paquets = Paquet.find(@params[:paquet_ids]) if @params[:paquet_ids]
    if @demande.save
      flash[:notice] = 'La demande a bien été créée.'
      Notifier::deliver_demande_nouveau({:demande => @demande, 
                                          :nom => @session[:user].nom, 
                                          :controller => self}, flash)
      redirect_to :action => 'list'
    else
      new
      render :action => 'new' 
    end
  end 

  def ajax_update_beneficiaire
    return unless request.xhr?
    output = ""
    params.each_pair {|key, value| output << key.to_s + " : " + value.to_s + "<br />" }
    beneficiaire = Beneficiaire.find params[:beneficiaire_id]
    contrats = Contrat.find :all, :conditions => ["client_id=?", beneficiaire.client.id ]
    contrats.each {|c| output << c.support.nom}
    render_text output
  end

  def ajax_update_delai
    return render_text('') unless request.xhr? and params[:demande] and (params[:demande][:logiciel_id] != "")
    output = ""
#    params.each_pair {|key, value| output << key.to_s + " : " + value.to_s + "<br />" }
    beneficiaire = Beneficiaire.find params[:demande][:beneficiaire_id]
    contrat = Contrat.find :first, :conditions => ["client_id=?", beneficiaire.client.id ]
    return render_text(" => pas de contrat, pas de support logiciel libre") unless contrat and beneficiaire
    logiciel = Logiciel.find(params[:demande][:logiciel_id])
    # 6 est l'arch source
    paquets = beneficiaire.client.paquets.\
    find_all_by_logiciel_id(logiciel.id, 
                            :conditions => [ "paquets.arch_id <> ? ", 6 ],
                            :order => "socle_id DESC")

    severite = Severite.find(params[:demande][:severite_id]) 
    typedemande = Typedemande.find(params[:demande][:typedemande_id])
    return render_text('') unless paquets and severite and typedemande
    selecteds = params[:paquet_ids]

    case paquets.size
     when 0
      output << "<p>Nous ne disposons d'aucun paquet binaire concernant " + logiciel.nom  + "</p>" 
     when paquets.size < 0
      # n'est jamais appelé ? la condition n'est pas bonne
      output << "<p>Une erreur s'est produite concernant les paquets de " + logiciel.nom  + "</p>"
     else 
      output << "<p>Précisez ici les paquets impactés par la demande :</p>" 
    
      output << "<table>"
      output << "<tr><td> <b>Paquets</b> </td>"
      output << "<td> Contournement  </td><td> Correction  </td><tr>"
      
      paquets.each {|p| 
        contrat = Contrat.find(p.contrat.id)
        engagement = contrat.engagements.find_by_typedemande_id_and_severite_id(typedemande.id, severite.id)
        output << "<tr><td>"
        #TODO : remplacer ce truc par un <%= check_box ... %>
        output << "<input type=\"checkbox\" id=\"#{p.id}\""
        output << " name=\"paquet_ids[]\" value=\"#{p.id}\""
        output << " checked=\"checked\"" if selecteds and selecteds.include? p.id.to_s
        output << ">#{p.socle.nom} (#{p.arch.nom}) : "
        output << "#{p.nom}-#{p.version}-#{p.release}</td>"
        if engagement
          output << "<td><%= display_jours #{engagement.contournement}%> </td>"
          output << "<td><%= display_jours #{engagement.correction}%> </td>"
        end
        output << "</tr>"
      }
      output << "</table>"
    end
    
    render :inline => output
  end


  def edit
    @demande = Demande.find(params[:id])
    common_form @beneficiaire
  end

  def bench
    @demande = Demande.find(params[:id])
#    contrat = Contrat.find(4)
    @test = Demande.find(134).engagement(4)
#    @engagement = @demande.engagement(contrat)
  end

  def comment
    @demande = Demande.find(params[:id]) unless @demande
    @count = Demande.count(:conditions => [ "logiciel_id = ?", @demande.logiciel_id ] )
    if @beneficiaire
      @commentaires = Commentaire.find_all_by_demande_id_and_prive(@demande.id, false, :order => "created_on DESC")
    elsif @ingenieur
      @commentaires = Commentaire.find_all_by_demande_id(@demande.id, :order => "created_on DESC")
    end
    flash[:warn] = "Cette demande n'a pas de statut, " + 
      "veuillez contacter la cellule" unless @demande.statut
    @statuts = @demande.statut.possible()
    @correctifs = Correctif.find_all if @demande.statut_id == 4 # Analysée

    # Elle est grosse celle là, mais elle marche bien ^_^
    joins = 'INNER JOIN ingenieurs ON ingenieurs.identifiant_id=identifiants.id '
    # joins << ' INNER JOIN contrats_ingenieurs ON contrats_ingenieurs.ingenieur_id=ingenieurs.id '
    # joins << ' INNER JOIN contrats ON contrats.id=contrats_ingenieurs.contrat_id '
    # conditions = [ 'contrats.client_id = ?', @demande.client.id ]
    @identifiants_ingenieurs = 
      Identifiant.find(:all, :select => "DISTINCT identifiants.* ",
                       :joins => joins)
  end

  def update
    @demande = Demande.find(params[:id])
    common_form @beneficiaire
    @demande.paquets = Paquet.find(@params[:paquet_ids]) if @params[:paquet_ids]
    if @demande.update_attributes(params[:demande])
      flash[:notice] = 'La demande a bien été mise à jour.'
      redirect_to :action => 'comment', :id => @demande
    else
      render :action => 'edit'
    end
  end

  def destroy
    Demande.find(params[:id]).destroy
    redirect_to :back
  end

  def changer_statut
    return unless params[:demande][:id] and params[:demande][:statut_id]
    @demande = Demande.find(params[:demande][:id])
    changement = Demandechange.new
    changement.statut = @demande.statut
    changement.demande = @demande
    # migration 006 :
    changement.identifiant = @session[:user]
    if @demande.update_attributes(params[:demande]) and changement.save
      flash[:notice] = "<br />Le statut a été mis à jour"
      Notifier::deliver_demande_change_statut({:demande => @demande, 
                                                :nom => @session[:user].nom, 
                                                :controller => self},
                                              flash)
    else
      flash[:warn] = "Une erreur est survenue, veuillez nous contacter"
    end
    redirect_to :action => 'comment', :id => @demande.id
  end

  def changer_ingenieur
    redirect_to_comment unless params[:demande][:id] and params[:ingenieur_id]
    @demande = Demande.find(params[:demande][:id])
    @demande.ingenieur = Ingenieur.find_by_identifiant_id(params[:ingenieur_id])
    if @demande.save
      if @demande.ingenieur
        flash[:notice] = "La demande a été assignée correctement" 
        Notifier::deliver_demande_assigner({:demande => @demande, 
                                             :controller => self}, 
                                           flash)
      else
        flash[:notice] = "La demande n'est plus assignée"
      end
    else
      flash[:warn] = "Une erreur est survenue, veuillez nous contacter"
    end
    redirect_to_comment
  end


  def associer_correctif
    return unless params[:demande][:id] and params[:correctif_id]
    @demande = Demande.find(params[:demande][:id])
    if @demande.update_attributes(:correctif_id => params[:correctif_id])
      flash[:notice] = "<br />Un correctif a été lié"
    else
      flash[:warn] = "Une erreur est survenue, veuillez nous contacter"
    end
    redirect_to :action => 'comment', :id => @demande.id
  end


  private
  def common_form(beneficiaire)
    @ingenieurs = Ingenieur.find_all unless beneficiaire
    if beneficiaire
      client = beneficiaire.client
      @logiciels = client.logiciels
      @typedemandes = client.typedemandes
      @clients = [ client ] 
    else
      @logiciels = Logiciel.find(:all, :order => "nom")
      @typedemandes = Typedemande.find_all
      @clients = Client.find_all
    end
    @severites = Severite.find_all
  end

  # Ce code a été copié dans le controller de bienvenue (list)
  # C'est mal, il faudra trouver une solution
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

  def redirect_to_comment
    redirect_to :action => 'comment', :id => @demande
  end

end

#<%= observe_form "demande_form",
# {:url => {:action => :ajax_update_delai},
#  :update => :delai,
#  :frequency => 15 } %>
#<%= observe_field "demande_severite_id", {
#  :url => {:action => :ajax_update_delai}, 
#  :update => :delai,  
#  :with => "severite_id" } 
#%>
#<%= observe_field "demande_logiciel_id",
# {:url => {:action => :ajax_update_paquets},
#  :update => :demande_paquets,
#  :with => "logiciel_id"} %>


