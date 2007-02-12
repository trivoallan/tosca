#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class DemandesController < ApplicationController
  before_filter :verifie, 
  :only => [ :comment, :edit, :update, :destroy, :changer_statut ]

  helper :correctifs

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }


  # verifie :
  # - s'il il y a un demande_id en paramètre (sinon :  retour à la liste)
  # - si une demande ayant cet id existe (sinon : erreur > rescue > retour à la liste)
  # - dans le cas d'un bénéficiaire, s'il est bien beneficiaire de cette demande (sinon : retour à la liste)
  def verifie
    super(Demande, {:controller => 'demandes'})
  end

  def index
    list
    render :action => 'list'
  end


  def raz_recherche
    @session[:filtres] = {}
    redirect_to :back
  end

  def list
    #TODO  
    #super(params) # see before_filter:set_filters in application.rb
    return unless session[:user]
    #cas spécial : consultation directe
    redirect_to :action => :comment, :id => params['numero'] if params['numero'] 

    #init des variables utilisées dans la vue
    #Logiciel.with_exclusive_scope() do
      @logiciels = Logiciel.find(:all)
    #end
    Client.with_exclusive_scope do
      @clients = Client.find(:all)
    end
    @beneficiaires = Beneficiaire.find(:all)

    @severites = Severite.find(:all)
    @statuts = Statut.find(:all)
    @types = Typedemande.find(:all)

    #Identifiant.find_all where ingenieur
    # joins = 'INNER JOIN ingenieurs ON ingenieurs.identifiant_id = identifiants.id'
    # @identifiants_ingenieurs = Identifiant.find(:all, :joins => joins)
    # TODO : VA MLO : il faut la liste des ingénieurs, non ?
    @ingenieurs = Ingenieur.find(:all)

    @count = Demande.count

    # les filtres sont définis dans le controller principal
    # see set_filters, @session[:filtres]

    if not @beneficiaire and not @ingenieur
      flash[:warn] = 'Vous n\'êtes pas identifié comme appartenant à un groupe.\
                        Veuillez nous contacter pour nous avertir de cet incident.'
      @demandes = [] # renvoi un tableau vide
    end

    Beneficiaire.with_scope(:find => {:include => [:identifiant, :client]}) do
      @demande_pages, @demandes = paginate :demandes, :per_page => 20,
      :order => 'updated_on DESC', #:conditions => conditions,
      :include => [:severite,:beneficiaire,:ingenieur,:typedemande,:statut,:logiciel]
    end
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
    @demande.paquets = Paquet.find(params[:paquet_ids]) if params[:paquet_ids]
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

  def ajax_update_delai
    return render_text('') unless request.xhr? and params[:demande] and (params[:demande][:logiciel_id] != "")
    output = ''
#    params.each_pair {|key, value| output << key.to_s + " : " + value.to_s + "<br />" }
    beneficiaire = Beneficiaire.find params[:demande][:beneficiaire_id]
    contrat = Contrat.find :first, :conditions => ['client_id=?', beneficiaire.client.id ]
    return render_text(' => pas de contrat, pas de support logiciel libre') unless contrat and beneficiaire
    logiciel = Logiciel.find(params[:demande][:logiciel_id])
    # 6 est l'arch source
    paquets = beneficiaire.client.paquets.\
    find_all_by_logiciel_id(logiciel.id, 
                            :order => 'paquets.nom DESC')

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
        output << "> : "
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
    conditions = [ "logiciel_id = ?", @demande.logiciel_id ] 
    @count = Demande.count(:conditions => conditions)
    if @beneficiaire
      @commentaires = Commentaire.find_all_by_demande_id_and_prive(
                      @demande.id, false, :order => "created_on DESC", 
                      :include => [:identifiant])
    elsif @ingenieur
      @commentaires = Commentaire.find_all_by_demande_id(
                      @demande.id, :order => "created_on DESC", 
                      :include => [:identifiant])
    end
    flash[:warn] = Metadata::DEMANDE_NOSTATUS unless @demande.statut

    @statuts = @demande.statut.possible()
    if (@demande.statut_id == 4 || @demande.statut_id == 5)
      @correctifs = Correctif.find_all 
    end

    # On va chercher les identifiants des ingénieurs assignés
    # C'est un héritage du passé
    # TODO : s'en débarrasser avec une migration et un :include
    joins = 'INNER JOIN ingenieurs ON ingenieurs.identifiant_id=identifiants.id'
    conditions = [' ingenieurs.id != ?', @demande.ingenieur_id || 0] 
    select = "DISTINCT identifiants.* "
    @identifiants_ingenieurs = 
      Identifiant.find(:all, :select => select, :joins => joins, :conditions => conditions)
  end

  def update
    @demande = Demande.find(params[:id])
    common_form @beneficiaire
    @demande.paquets = Paquet.find(params[:paquet_ids]) if params[:paquet_ids]
    if @demande.update_attributes(params[:demande])
      flash[:notice] = 'La demande a bien été mise à jour.'
      redirect_to :action => 'comment', :id => @demande
    else
      render :action => 'edit'
    end
  end

  def destroy
    Demande.find(params[:id]).destroy
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
    redirect_to_comment unless params and params[:id] and params[:ingenieur_id]
    @demande = Demande.find(params[:id])
    @demande.ingenieur = Ingenieur.find_by_identifiant_id(params[:ingenieur_id])
    if @demande.save
      if @demande.ingenieur
        flash[:notice] = "La demande a été assignée correctement" 
        Notifier::deliver_demande_assigner({:demande => @demande, 
                                             :controller => self}, 
                                           flash)
      else flash[:notice] = "La demande n'est plus assignée"
      end
    else flash[:warn] = "Une erreur est survenue, veuillez nous contacter"
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

  def deposer
    @demande = @demande || Demande.new(params[:demande])
    flash[:warn] = nil

    # On réinitialise tout le bouzin si on a changé le client
    if (params[:fake] and 
          @demande.client.id != params[:fake][:client_id])
      client = Client.find(params[:fake][:client_id])
      benefs = client.beneficiaires
      # Demande.new
      @demande.beneficiaire = benefs.first 
      if benefs.empty?
        message = ": #{client.nom} n'en a pas, veuillez corriger sa fiche client"
        @demande.errors.add_on_empty(:beneficiaire, message)
        @demande.beneficiaire = Beneficiaire.find(:first)
      end
    end

    # On positionne des paramètres par défaut
    if @demande.beneficiaire_id == 0
      @demande.beneficiaire_id = 1 if @ingenieur
      @demande.beneficiaire = @beneficiaire.id if @beneficiaire
      if @demande.beneficiaire_id == 0
        message = 'Votre identification est incomplète, veuillez nous contacter au plus vite'
        @demande.errors.add_on_empty(:beneficiaire, message)
        @demande.beneficiaire = Beneficiaire.find(:first)
      end
    end
    fill_with_first('typedemande') if @demande.typedemande_id == 0
    fill_with_first('severite') if @demande.severite_id == 0
    fill_with_first('socle') if @demande.socle_id == 0
    fill_with_first('logiciel') if @demande.logiciel_id == 0
    # return unless @demande.errors.empty?

    # @demande.paquet_ids = params[:paquet_ids] if params[:paquet_ids]
    # @demande.binaire_ids = params[:binaire_ids] if params[:binaire_ids]

    @params = params
    _form 
    # ajax, quand tu nous tiens ;)
    if request.xhr?
      render :partial => 'form_deposer', :layout => false
    end
  end


  private
  def _form
    if @ingenieur
      @clients = Client.find(:all, :select => 'id, clients.nom')
      @client_id = @demande.client.id 
    end
    conditions = [ 'binaires.socle_id = ? ', @demande.socle_id ]
    options = { :conditions => conditions, :include => [:binaires], 
      :order => 'paquets.nom DESC' }
    @paquets = @demande.client.paquets.\
      find_all_by_logiciel_id(@demande.logiciel_id, options)
    @binaires = @paquets.collect{|p| p.binaires}.flatten
  end

  # Remplit une @demande avec l'id de 'param', dispo via le client 
  def fill_with_first(param)
    @test = "on remplit avec #{param} <br />" + @test.to_s
    collection = @demande.client.send(param.pluralize)
    if collection.empty?
      message = ": #{@demande.client.nom} n'a aucun #{param}," +
        ' veuillez nous contacter au plus vite'
      @demande.errors.add_on_empty(:"#{param}", message)
    else
      @demande.send("#{param}=", collection.first)
    end
  end

  def common_form(beneficiaire)
    @ingenieurs = Ingenieur.find_all unless beneficiaire
    if beneficiaire
      client = beneficiaire.client
      @logiciels = client.logiciels
      @typedemandes = client.typedemandes
      @clients = [ client ] 
    else
      @logiciels = Logiciel.find(:all, :order => 'logiciels.nom')
      @typedemandes = Typedemande.find_all
      @clients = Client.find_all
    end
    @severites = Severite.find_all
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


