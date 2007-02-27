#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################

# Controller general de l'application
# Les filtres ajoutés à ce controller seront chargés pour tous les autres.
# De même, toutes les méthodes ajoutées ici seront disponibles.

# authentification
require_dependency "login_system"
# gestion des roles et des permissions
# en cas de soucis : http://wiki.rubyonrails.com/rails/pages/LoginGeneratorACLSystem/versions/468
require_dependency "acl_system" 

class ApplicationController < ActionController::Base
  around_filter :scope_beneficiaire
  helper :filters

  before_filter :set_headers
  before_filter :set_global_shortcuts
  before_filter :login_required, :except => [:refuse, :login]

  # systems d'authentification 
  include LoginSystem
  include ACLSystem

  # layout standard
  layout "standard-layout"

  # variables globales (beurk, mais tellement pratique ;))
  def set_global_shortcuts
    @ingenieur = session[:ingenieur]
    @beneficiaire = session[:beneficiaire]
  end


protected
   
  # redirection à l'accueil
  # TODO : certain redirect_to_home devrait etre redirect_back
  def redirect_to_home
    redirect_to :controller => 'bienvenue', :action => "list"
  end
 
  # redirection par défaut en cas d'erreur / de non droit
  def redirect_back
    redirect_back_or_default :controller => 'bienvenue', :action => "list"
  end

  def set_headers
    headers['Content-Type'] = ( request.xhr? ? 'text/javascript; charset=utf-8' : 
                                               'text/html; charset=utf-8' )
  end

  #   # fill up the new filter(s)
  #   # sended from POST request
   def set_filters
     session[:filters] ||= {}

    # les filtres sont nommés "filtres[nom_du_parametre]"
     if params[:filters]
       params.each{ |p| set_filter(p.first) }
     end
  end

  # fill up one named filter from params
  def set_filter(filtre, options = {})
    value = params[:filters][filtre]
    if value != ''
      value = value.to_i if filtre =~ /(_id)$/
      session[:filters][filtre] = value
    else
      session[:filters][filtre] = nil
    end
  end

  def remove_filters
    session[:filters] = {}
    redirect_to :back
  end

  # Compute scope from args sended
  # Call it :
  #  sdocuments = compute_scope(nil, ['paquet_id = ?', 3])
  def compute_scope(include = nil, *args)
    args.compact!
    return {} if args.empty? or args.first.nil?

    # si conditions est une condition (et non pas un tableau de conditions)
    # on vire les nil
    query, params = [], []
    args.each do |condition| 
      query.push condition[0] 
      params.concat condition[1..-1]
    end

    #query.compact!
    computed_conditions = [ query.join(' AND ') ] + params
    computed_conditions.compact!
    return {} if computed_conditions[0] == ''
    return {:find => {:conditions => computed_conditions, :include => include}} 
  end

  # verifie :
  # - s'il il y a un id en paramètre (sinon :  retour à la liste)
  # - si un ActiveRecord ayant cet id existe (sinon : erreur > rescue > retour à la liste)
  # options
  # :controller en cas de redirection (bienvenue)
  # :action en cas de redirection (list)
  # TODO : trop de copier-coller 
  # NOTODO : "options[:controller] = controller_name" par défaut
  #       c'est idéal, mais les clients n'ont pas les droits sur tous les */list
  #       on tombe alors sur un acces/refuse, dommage
  def verifie(ar, options = {:controller => 'bienvenue', :action => 'list'})
    if !params[:id]
      flash.now[:warn] = 'Veuillez préciser l\'identifiant de la demande à consulter.'
      redirect_to(options) and return false
    end
    scope_beneficiaire {
      object = ar.find(params[:id], :select => 'id') 
      if object = nil
        flash.now[:warn] = "Aucun(e) #{ar.to_s} ne correspond à l'identifiant #{params[:id]}."
        redirect_to(options) and return false
      end
    }
    true
  rescue  ActiveRecord::RecordNotFound
    flash.now[:warn] = "Aucun(e) #{ar.to_s} ne correspond à l'identifiant #{params[:id]}."
    redirect_to(options) and return false
  end

  # overriding for escaping count of include (eager loading)
  def count_collection_for_pagination(model, options)
    if options[:conditions]
      model.count({ :joins => options[:joins],
                    :conditions => options[:conditions],
                    :include => options[:include],
                    :select => options[:count] })
    else
      model.count({ :joins => options[:joins],
                    :select => options[:count] })
    end
  end


private
  # scope imposé sur toutes les vues, 
  # pour limiter ce que peuvent voir nos clients
  # TODO : check les interférences avec les filtres
  def scope_beneficiaire
    beneficiaire = session[:beneficiaire]
    if beneficiaire
      client_id = beneficiaire.client_id
      contrat_ids = beneficiaire.contrat_ids 

      # damn fast with_scope (MLO ;))
      Binaire.set_scope(contrat_ids)
      Client.set_scope(client_id)
      Contribution.set_scope(contrat_ids)
      Demande.set_scope(client_id)
      Document.set_scope(client_id) 
      Logiciel.set_scope(contrat_ids)
      Paquet.set_scope(contrat_ids)
      Socle.set_scope(client_id)
      #Piecejointe.set_scope(client_id) #only for files
    end
    yield
  end

  # met le scope client en session
  # ca permet de ne pas recharger les ids contrats 
  # à chaque fois
  # call it like this : scope_client(params['filters']['client_id'])
  def scope_client(value)
    if value == '' 
      session[:contrat_ids] = nil 
    else
      conditions = { :client_id => value.to_i }
      options = { :select => 'id', :conditions => conditions }
      session[:contrat_ids] = Contrat.find(:all, options).collect{|c| c.id}
    end
  end

  def scope_filter
    filtres = session[:filters]


    # on construit les conditions pour les demandes et les logiciels
    cidentifiant = ['identifiants.id = ? ', filtres['identifiant_id'] ] if filtres['identifiant_id'] 
    cdemande_severite = ['demandes.severite_id = ? ', filtres['severite_id'] ] if filtres['severite_id'] 
    cdemande_motcle = ['(demandes.resume LIKE ? OR demandes.description LIKE ?) ', 
                        "%#{filtres['motcle']}%", "%#{filtres['motcle']}%"] if filtres['motcle']
    cdemande_ingenieur = ['demandes.ingenieur_id = ? ', filtres['ingenieur_id'] ] if filtres['ingenieur_id']
    cdemande_beneficiaire = ['demandes.beneficiaire_id = ? ', filtres['beneficiaire_id'] ] if filtres['beneficiaire_id']
    cdemande_type = ['demandes.typedemande_id = ? ', filtres['typedemande_id'] ] if filtres['typedemande_id']
    cdemande_statut = ['demandes.statut_id = ? ', filtres['statut_id'] ] if filtres['statut_id']
    clogiciel = [ 'logiciels.id = ? ', filtres['logiciel_id'] ] if filtres['logiciel_id'] 
    ccontribution_logiciel = [ 'logiciel_id = ? ', filtres['logiciel_id'] ] if filtres['logiciel_id'] 
    cclassification_groupe = ['classifications.groupe_id = ? ', filtres['groupe_id'] ] if filtres['groupe_id']

    ###########
    client_id = filtres['client_id'].to_i if filtres['client_id']
    contrat_ids = filtres['contrat_ids'] if filtres['contrat_ids']
    
    if client_id
      cclient = ['clients.id = ? ', client_id ] 
      cbeneficiaire_client = ['beneficiaires.client_id = ? ', client_id ] 
      cdocument_client = ['documents.client_id = ? ', client_id ]
    end

    sbeneficiaire = compute_scope(nil, cbeneficiaire_client)
    sdocuments = compute_scope(nil, cdocument_client)
    sclients = compute_scope(nil, cclient)
    #########

    sidentifiant = compute_scope(nil, cidentifiant)
    sdemandes = compute_scope([:logiciel,:beneficiaire],
                              cdemande_severite, 
                              cdemande_motcle, 
                              cdemande_ingenieur, 
                              cdemande_beneficiaire, 
                              cdemande_type,
                              cbeneficiaire_client,
                              clogiciel, 
                              cdemande_statut)
    slogiciels = compute_scope([:classifications], clogiciel, cclassification_groupe)
    scontributions = compute_scope(nil, ccontribution_logiciel)
    spaquets = compute_scope([:logiciel], clogiciel)

    Beneficiaire.with_scope(sbeneficiaire) {
    Client.with_scope(sclients) {
    Document.with_scope(sdocuments) {
    Identifiant.with_scope(sidentifiant) {
    Demande.with_scope(sdemandes) {
    Logiciel.with_scope(slogiciels) {  
    Contribution.with_scope(scontributions) {
    Paquet.with_scope(spaquets) {
      yield }}}}}}}}
  end

end



