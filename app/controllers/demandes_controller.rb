#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class DemandesController < ApplicationController
  # auto_complete_for :logiciel, :nom
  # auto_complete_for :demande, :resume

  helper :filters, :contributions, :logiciels, :export, :appels, :socles

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def index
    list
    render :action => 'list'
  end

  # We don't use finder for this overused view
  # It's about 40% faster with this crap (from 2.8 r/s to 4.0 r/s)
  # it's not enough, but a good start :)
  SELECT_LIST = 'demandes.*, severites.nom as severites_nom, ' + 
    'logiciels.nom as logiciels_nom, id_benef.nom as beneficiaires_nom, ' +
    'typedemandes.nom as typedemandes_nom, clients.nom as clients_nom, ' +
    'id_inge.nom as ingenieurs_nom '
  JOINS_LIST = 'INNER JOIN severites ON severites.id=demandes.severite_id ' + 
    'INNER JOIN beneficiaires ON beneficiaires.id=demandes.beneficiaire_id '+
    'INNER JOIN identifiants id_benef ON id_benef.id=beneficiaires.identifiant_id '+
    'INNER JOIN clients ON clients.id = beneficiaires.client_id '+
    'LEFT OUTER JOIN ingenieurs ON ingenieurs.id = demandes.ingenieur_id ' + 
    'LEFT OUTER JOIN identifiants id_inge ON id_inge.id=ingenieurs.identifiant_id '+
    'INNER JOIN typedemandes ON typedemandes.id = demandes.typedemande_id ' + 
    'INNER JOIN statuts ON statuts.id = demandes.statut_id ' + 
    'LEFT OUTER JOIN logiciels ON logiciels.id = demandes.logiciel_id '


  def list
    #cas spécial : consultation directe
    if params['numero'] 
      redirect_to :action => :comment, :id => params['numero'] 
    end

    options = { :per_page => 10, :order => 'updated_on DESC', 
      :select => SELECT_LIST, :joins => JOINS_LIST }
    conditions = []

    params['logiciel'].each_pair { |key, value|
      conditions << " logiciels.#{key} LIKE '%#{value}%'" if value != ''
    } if params['logiciel']
    params['demande'].each_pair { |key, value|
      conditions << " demandes.#{key} LIKE '%#{value}%'" if value != ''
    } if params['demande']
    params['filters'].each_pair { |key, value|
      conditions << " #{key}=#{value} " unless value == '' 
    } if params['filters']


    # query. Le flash est utilisé pour un export des données visionnées
    unless conditions.empty?
      flash[:conditions] = options[:conditions] = conditions.join(' AND ') 
    end


    escope = {}
    if @beneficiaire
      escope = Demande.get_scope_without_include([@beneficiaire.client_id])
    end
    if @ingenieur
      escope = Demande.get_scope_without_include(@ingenieur.client_ids)
    end
    # cet exclusive scope sert à ne pas se faire effacer les jointures
    # c'est ça ou 7 include ... :/
    Demande.with_exclusive_scope(escope) do
      @demande_pages, @demandes = paginate :demandes, options
    end

    # panel on the left side
    if request.xhr? 
      render :partial => 'requests_list', :layout => false
    else
      _panel
      @partial_for_summary = 'requests_info'
    end
  end


  def new
    @demande = Demande.new unless @demande
    _form @beneficiaire

    # si on est ingénieur, elle est pour nous par défaut
    @demande.ingenieur = @ingenieur
    # sans object par défaut 
    @demande.severite_id = 4
    # statut "prise en compte" si ingénieur, sinon : "enregistrée"
    @demande.statut_id = (@ingenieur ? 2 : 1)

    @demande.beneficiaire_id = @beneficiaire.id if @beneficiaire
  end

  def create
    @demande = Demande.new(params[:demande])
    if @demande.save
      flash[:notice] = 'La demande a bien été créée.'
      Notifier::deliver_demande_nouveau({:demande => @demande, 
                                          :nom => @session[:user].nom, 
                                          :controller => self}, flash)
      redirect_to :action => 'list'
    else
      _form @beneficiaire
      render :action => 'new' 
    end
  end 


  # TODO : passer au nouveau formulaire (deposer), 
  # qui a besoin d'un petit check
  # et virer ce vieux code legacy tout laid
  def ajax_update_delai
    return render_text('') unless request.xhr? and 
      params[:demande] and (params[:demande][:logiciel_id] != "")
    output = ''

    beneficiaire = Beneficiaire.find params[:demande][:beneficiaire_id]
    contrat = Contrat.find :first, :conditions => ['client_id=?', beneficiaire.client.id ]
    unless contrat and beneficiaire
      return render_text(' => pas de contrat, pas d\'ossa') 
    end
    logiciel = Logiciel.find(params[:demande][:logiciel_id])
    # 6 est l'arch source
    paquets = beneficiaire.client.paquets.\
    find_all_by_logiciel_id(logiciel.id, 
                            :order => 'paquets.nom DESC')

    severite = Severite.find(params[:demande][:severite_id]) 
    typedemande = Typedemande.find(params[:demande][:typedemande_id])
    return render_text('') unless paquets and severite and typedemande
    selecteds = params[:demande][:paquet_ids]

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
        output << " name=\"demande[paquet_ids][]\" value=\"#{p.id}\""
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
    _form @beneficiaire
  end

  def comment
    @demande = Demande.find(params[:id]) unless @demande
    conditions = [ "logiciel_id = ?", @demande.logiciel_id ] 
    @count = Demande.count(:conditions => conditions)
    # TODO c'est pas dry, cf ajax_comments
    options = { :order => 'created_on DESC', :include => [:identifiant], 
      :limit => 1, :conditions => { :demande_id => @demande.id } }
    options[:conditions][:prive] = false if @beneficiaire
    @last_commentaire = Commentaire.find(:first, options)    
    flash.now[:warn] = Metadata::DEMANDE_NOSTATUS unless @demande.statut

    @statuts = @demande.statut.possible().collect{ |s| [ s.nom, s.id] }
    options =  { :conditions => 
      ['contributions.logiciel_id = ?', @demande.logiciel_id ] }
    @contributions = Contribution.find(:all, options)
    @ingenieurs = Ingenieur.find_select(Identifiant::SELECT_OPTIONS)
    
    # On va chercher les identifiants des ingénieurs assignés
    # C'est un héritage du passé
    # TODO : s'en débarrasser avec une migration et un :include'
    joins = 'INNER JOIN ingenieurs ON ingenieurs.identifiant_id=identifiants.id'
    select = "DISTINCT identifiants.id "
    @identifiants_ingenieurs = 
      Identifiant.find(:all, :select => select, :joins => joins)

    @partial_for_summary = 'infos_demande'
  end

  def ajax_description
    return render_text('') unless request.xhr? and params[:id]
    @demande = Demande.find(params[:id]) unless @demande
    render :partial => 'tab_description', :layout => false
  end

  def ajax_comments
    return render_text('') unless request.xhr? and params[:id]
    @demande_id = params[:id] 
    if @beneficiaire
      @commentaires = Commentaire.find_all_by_demande_id_and_prive(
                      @demande_id, false, :order => "created_on ASC", 
                      :include => [:identifiant])
    elsif @ingenieur
      @commentaires = Commentaire.find_all_by_demande_id(
                      @demande_id, :order => "created_on ASC", 
                      :include => [:identifiant])
    end
    # On va chercher les identifiants des ingénieurs assignés
    # C'est un héritage du passé
    # TODO : s'en débarrasser avec une migration et un :include
    joins = 'INNER JOIN ingenieurs ON ingenieurs.identifiant_id=identifiants.id'
    select = "DISTINCT identifiants.* "
    @identifiants_ingenieurs = 
      Identifiant.find(:all, :select => select, :joins => joins)

    render :partial => "tab_comments", :layout => false
  end

  def ajax_history
    return render_text('') unless request.xhr? and params[:id]
    @demande = Demande.find(params[:id]) unless @demande
    render :partial => 'tab_history', :layout => false
  end


  def ajax_appels
    return render_text('') unless request.xhr? and params[:id]
    @demande_id = params[:id] 
    conditions = [ 'appels.demande_id = ? ', @demande_id ]
    options = { :conditions => conditions, :order => 'appels.debut', 
      :include => [:beneficiaire,:ingenieur,:contrat,:demande] }
    @appels = Appel.find(:all, options)
    render :partial => 'tab_appels', :layout => false
  end

  def ajax_piecejointes
    return render_text('') unless request.xhr? and params[:id]
    @demande_id = params[:id] 
    conditions = [ 'commentaires.demande_id = ? ', @demande_id ]
    options = { :conditions => conditions, :order => 
      'commentaires.updated_on DESC', :include => [:commentaire] }
    @piecejointes = Piecejointe.find(:all, options)
    render :partial => 'tab_piecejointes', :layout => false
  end

  def ajax_cns
    return render_text('roh') unless request.xhr? and params[:id]
    @demande = Demande.find(params[:id]) unless @demande
    render :partial => 'tab_cns', :layout => false
  end

  def update
    @demande = Demande.find(params[:id])
    @demande.paquets = Paquet.find(params[:paquet_ids]) if params[:paquet_ids]
    if @demande.update_attributes(params[:demande])
      flash[:notice] = 'La demande a bien été mise à jour.'
      redirect_to :action => 'comment', :id => @demande
    else
      _form @beneficiaire
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
    @demande.update_attributes!(params[:demande]) and changement.save
    flash[:notice] = "Le statut a été mis à jour"
    Notifier::deliver_demande_change_statut({:demande => @demande, 
                                              :nom => @session[:user].nom, 
                                              :controller => self},
                                            flash)
    redirect_to :action => 'comment', :id => @demande.id
  end

  def changer_ingenieur
    return render_text('') unless params[:id] and params[:ingenieur_id]
    @demande = Demande.find(params[:id])
    @demande.ingenieur = Ingenieur.find(params[:ingenieur_id].to_i)
    @demande.save!
    if @demande.ingenieur
      flash[:notice] = "La demande a été assignée correctement" 
      options = {:demande => @demande, :controller => self}
      Notifier::deliver_demande_assigner(options, flash)
    else
      flash[:notice] = "La demande n'est plus assignée"
    end
    redirect_to_comment
  end


  def associer_contribution
    return render_text('') unless params[:id] and params[:contribution_id]
    @demande = Demande.find(params[:id])
    @demande.update_attributes!(:contribution_id => params[:contribution_id])
    flash[:notice] = "Une contribution a été liée"
    redirect_to :action => 'comment', :id => @demande.id
  end


  # TODO : trop lent et pas encore au point
  # mis en privé pour cette release, à corriger pour la suivante
  def deposer
    @demande ||= Demande.new(params[:demande])
    flash.now[:warn] = nil

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
#     fill_with_first('typedemande') if @demande.typedemande_id == 0
#     fill_with_first('severite') if @demande.severite_id == 0
#     fill_with_first('socle') if @demande.socle_id == 0
#     fill_with_first('logiciel') if @demande.logiciel_id == 0
    @binaires = []
    # return unless @demande.errors.empty?
    @params = params
    _form nil
    # ajax, quand tu nous tiens ;)
    if request.xhr?
      render :partial => 'form_deposer', :layout => false
    end
  end


  private
#   def _form
#     if @ingenieur
#       @clients = Client.find(:all, :select => 'id, clients.nom')
#       @client_id = @demande.client.id 
#     end
#     conditions = [ 'binaires.socle_id = ? ', @demande.socle_id ]
#     options = { :conditions => conditions, :include => [:binaires], 
#       :order => 'paquets.nom DESC' }
#     @paquets = @demande.client.paquets.\
#       find_all_by_logiciel_id(@demande.logiciel_id, options)
#     @binaires = @paquets.collect{|p| p.binaires}.flatten
#   end


  # Remplit une @demande avec l'id de 'param', dispo via le client 
  def fill_with_first(param)
    collection = @demande.client.send(param.pluralize)
    if collection.empty?
      message = ": #{@demande.client.nom} n'a aucun #{param}," +
        ' veuillez nous contacter au plus vite'
      @demande.errors.add_on_empty(param.intern, message)
    else
      @demande.send("#{param}=", collection.first)
    end
  end

  def _panel
    @clients = Client.find_select()
    @statuts = Statut.find_select()
    @typedemandes = Typedemande.find_select()
    @severites = Severite.find_select()
    @ingenieurs = Ingenieur.find_select(Identifiant::SELECT_OPTIONS)
    @beneficiaires = Beneficiaire.find_select(Identifiant::SELECT_OPTIONS)

    softwares = { :select => 'demandes.logiciel_id', :distinct => true }
    @count = { :demandes =>  Demande.count,
      :logiciels => Demande.count(softwares),
      :commentaires => Commentaire.count,
      :piecejointes => Piecejointe.count,
      :contributions => Contribution.count }
  end

  # todo à retravailler
  def _form(beneficiaire)
    @socles = Socle.find_select
    if beneficiaire
      client = beneficiaire.client
      @logiciels = client.logiciels
      @typedemandes = client.typedemandes
      @clients = [ client ] 
    else
      @ingenieurs = Ingenieur.find_select(Identifiant::SELECT_OPTIONS)
      @logiciels = Logiciel.find_select
      @typedemandes = Typedemande.find_select
      @clients = Client.find(:all)
    end
    @severites = Severite.find_select
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


