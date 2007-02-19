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
  
  # variable utilisateurs; nécessite session[:user]
  # penser à mettre à jour les pages statiques 404 et 500 en cas de modification
  def set_sessions
    session[:logo_lstm] = render_to_string :inline => 
      "<%=image_tag('logo_lstm.gif', :alt => 'Accueil', :title => 'Accueil' )%>"
    session[:logo_08000] = render_to_string :inline => 
      "<%=image_tag('logo_08000.gif', :alt => '08000 LINUX', :title => '08000 LINUX' )%>"
    return unless session[:user]
    session[:filters] = Hash.new
    session[:beneficiaire] = session[:user].beneficiaire
    session[:ingenieur] = session[:user].ingenieur
    session[:nav_links] = render_to_string :inline => "
        <% nav_links = [ 
          (link_to 'Accueil',:controller => 'bienvenue', :action => 'list'),
          (link_to 'Déconnexion',:controller => 'account', :action => 'logout'), 
          (link_to_my_account),
          (link_to 'Plan',:controller => 'bienvenue', :action => 'plan'),
          (link_to 'Utilisateurs', :controller => 'account', :action => 'list'),
          (link_to 'Rôles', :controller => 'roles', :action => 'list')
        ] %>
        <%= nav_links.compact.join('&nbsp;|&nbsp;') if session[:user] %>"
    session[:cut_links] = render_to_string :inline => "
        <% cut_links = [ 
          (link_to 'Demandes',:controller => 'demandes', :action => 'list') " +
          (session[:user].authorized?('demandes/list') ? "+ '&nbsp;' + search_demande," : ',' ) + 
         "(link_to 'Filtres',:controller => 'filtres', :action => 'index'),
          (link_to 'Logiciels',:controller => 'logiciels', :action => 'list'),
          (link_to 'Projets',:controller => 'projets', :action => 'list'),
          (link_to 'Tâches',:controller => 'taches', :action => 'list'),
          (link_to 'Correctifs',:controller => 'correctifs', :action => 'list'),
          (link_to 'Répertoire',:controller => 'documents', :action => 'select'), 
          (link_to_my_client), 
          (link_to 'Clients',:controller => 'clients', :action => 'list')
        ] %>
        <% form_tag(:controller => 'demandes', :action => 'list') do %>
        <%= cut_links.compact.join('&nbsp;|&nbsp;') %>
        <% end %>"
  end


  def set_headers
    if request.xhr?
      headers['Content-Type'] = 'text/javascript; charset=utf-8'
    else
      headers['Content-Type'] = 'text/html; charset=utf-8'
    end
  end

  #   # fill up the new filter(s)
  #   # sended from POST request
   def set_filters
     session[:filters] ||= {}

    # les filtres sont nommés "filtres[nom_du_parametre]"
    if params[:filters]
      params[:filters].each{ |p| set_filter(p.first) }
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
      flash[:warn] = 'Veuillez préciser l\'identifiant de la demande à consulter.'
      redirect_to(options) and return false
    end
    scope_beneficiaire {
      object = ar.find(params[:id], :select => 'id') 
      if object = nil
        flash[:warn] = "Aucun(e) #{ar.to_s} ne correspond à l'identifiant #{params[:id]}."
        redirect_to(options) and return false
      end
    }
    true
  rescue  ActiveRecord::RecordNotFound
    flash[:warn] = "Aucun(e) #{ar.to_s} ne correspond à l'identifiant #{params[:id]}."
    redirect_to(options) and return false
  end

  # overriding for escaping count of include (eager loading)
  def count_collection_for_pagination(model, options)
    model.count(:conditions => options[:conditions],
                :joins => options[:join] || options[:joins],
                :select => options[:count])
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
      Correctif.set_scope(contrat_ids)
      Demande.set_scope(client_id)
      Document.set_scope(client_id) 
      Logiciel.set_scope(contrat_ids)
      Paquet.set_scope(contrat_ids)
      Socle.set_scope(client_id)
    end
    yield
  end

  def scope_filter
    filtres = session[:filters]

    logger.debug('scope_filter : logiciel : ' + filtres['logiciel_id'].to_s)

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
    ccorrectif_logiciel = [ 'logiciel_id = ? ', filtres['logiciel_id'] ] if filtres['logiciel_id'] 
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
    sdemandes = compute_scope([:logiciel],
                              cdemande_severite, 
                              cdemande_motcle, 
                              cdemande_ingenieur, 
                              cdemande_beneficiaire, 
                              cdemande_type,
                              clogiciel, 
                              cdemande_statut)
    slogiciels = compute_scope([:classifications], clogiciel, cclassification_groupe)
    scorrectifs = compute_scope(nil, ccorrectif_logiciel)
    spaquets = compute_scope([:logiciel], clogiciel)

    Beneficiaire.with_scope(sbeneficiaire) {
    Client.with_scope(sclients) {
    Document.with_scope(sdocuments) {
    Identifiant.with_scope(sidentifiant) {
    Demande.with_scope(sdemandes) {
    Logiciel.with_scope(slogiciels) {  
    Correctif.with_scope(scorrectifs) {
    Paquet.with_scope(spaquets) {
      yield }}}}}}}}
  end

end



