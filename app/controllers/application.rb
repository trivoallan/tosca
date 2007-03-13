#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################

# Controller general de l'application
# Les filtres ajoutés à ce controller seront chargés pour tous les autres.
# De même, toutes les méthodes ajoutées ici seront disponibles.

# authentification
require_dependency "login_system"
# gestion des roles et des permissions
# Infos : http://wiki.rubyonrails.com/rails/pages/LoginGeneratorACLSystem/
require_dependency "acl_system" 

class ApplicationController < ActionController::Base
  # accès protégé et standardisé
  before_filter :set_global_shortcuts
  before_filter :login_required, :except => [:refuse, :login]

  # périmètre limité pour certains profils
  around_filter :scope

  # systems d'authentification 
  include LoginSystem
  include ACLSystem

  # layout standard
  layout "standard-layout"


protected  
  # redirection à l'accueil
  # TODO : certain redirect_to_home devrait etre redirect_back
  # TODO : faire une route nommée, c'est pas railsien cette fonction
  # TODO : trouver une meilleure solution, comme surcharger (un peu) 
  # le redirect_to de l'ActionController::Base
  # TODO : c'est mal, doublon avec le rescue du scope_beneficiaire
  def redirect_to_home
    if request.xhr?   
      render_text('<div class="information error">' + ERROR_MESSAGE + '</div>')
    else
      redirect_to :controller => 'bienvenue', :action => "list"
    end
  end
 
  # redirection par défaut en cas d'erreur / de non droit
  def redirect_back
    redirect_back_or_default :controller => 'bienvenue', :action => "list"
  end

  # variables globales (beurk, mais tellement pratique ;))
  # on en profite pour forcer une bonne en-tête.
  # TODO : verifier si ce header est encore nécessaire.
  def set_global_shortcuts
    headers['Content-Type'] =
      ( request.xhr? ? 'text/javascript; charset=utf-8' : 
        'text/html; charset=utf-8' )
    @ingenieur = session[:ingenieur]
    @beneficiaire = session[:beneficiaire]
  end


  # verifie :
  # - s'il il y a un id en paramètre 
  # - si un ActiveRecord ayant cet id existe 
  # options
  # :controller en cas de redirection (bienvenue)
  # :action en cas de redirection (list)
  # TODO : trop de copier-coller 
  # NOTODO : "options[:controller] = controller_name" par défaut
  #    c'est idéal, mais les clients n'ont pas les droits sur tous les */list
  #    on tombe alors sur un acces/refuse, dommage
  # TODO : find a pretty solution !
  WARN_NOID = 'Veuillez préciser l\'identifiant nécessaire à la consultation'
  def verifie(ar, options = {:controller => 'bienvenue', :action => 'list'})
    if !params[:id]
      flash.now[:warn] = WARN_NOID
      redirect_to(options) and return false
    end
    scope {
      object = ar.find(params[:id], :select => 'id') 
      if object = nil
        flash.now[:warn] = "Aucun(e) #{ar.to_s} ne correspond " + 
          "à l'identifiant #{params[:id]}."
        redirect_to(options) and return false
      end
    }
    true
  rescue  ActiveRecord::RecordNotFound
    flash.now[:warn] = "Aucun(e) #{ar.to_s} ne correspond " + 
      "à l'identifiant #{params[:id]}."
    redirect_to(options) and return false
  end

  # overriding for escaping count of include (eager loading)
  def count_collection_for_pagination(model, options)
    count_options = { :joins => options[:joins],
                      :select => options[:count] }
    if options[:conditions]
      count_options.update( { :conditions => options[:conditions],
                              :include => options[:include] } )
    end
    model.count(count_options)
  end

  # Surcharge en attendant que ce soit fixé dans la branche officielle
  def self.auto_complete_for(object, method, options = {})
    define_method("auto_complete_for_#{object}_#{method}") do
      column = object.to_s.pluralize + '.' + method.to_s
      find_options = { 
        :conditions => [ "LOWER(#{column}) LIKE ?", 
                         '%' + params[object][method].downcase + '%' ], 
        :order => "#{column} ASC",
        :limit => 10 }.merge!(options)
      
      @items = object.to_s.camelize.constantize.find(:all, find_options)
      
      render :inline => "<%= auto_complete_result @items, '#{method}' %>"
    end
  end

private
  # scope imposé sur toutes les vues, 
  # pour limiter ce que peuvent voir nos clients
  ERROR_MESSAGE = 'Une erreur est survenue. Notre service a été prévenu' + 
    ' et dispose des informations nécessaire pour corriger.<br />' +
    'N\'hésitez pas à nous contacter si le problème persiste.' 
  SCOPE_CLIENT = [ Client, Demande, Document, Socle ]
  SCOPE_CONTRAT = [ Binaire, Contrat, Contribution, Logiciel, Paquet ]
  # Cette fonction intègre un scope "maison", beaucoup plus rapide.
  # Il reste néanmoins intégralement safe
  # Le but est d'éviter les 15 imbrications de yield, trop couteuses
  def scope
    beneficiaire = session[:beneficiaire]
    ingenieur = session[:ingenieur]
    if beneficiaire
      client_ids = [ beneficiaire.client_id ]
      contrat_ids = beneficiaire.contrat_ids 
    end
    if ingenieur and not ingenieur.expert_ossa
      contrat_ids = ingenieur.contrat_ids 
      client_ids = ingenieur.client_ids
    end
    SCOPE_CONTRAT.each {|m| m.set_scope(contrat_ids) } if contrat_ids
    SCOPE_CLIENT.each {|m| m.set_scope(client_ids) } if client_ids
    begin
      yield
    ensure
      # SCOPE_CLIENT.each { |m| m.remove_scope() } if client_id
      # SCOPE_CONTRAT.each { |m| m.remove_scope() } if contrat_ids
    end
  rescue Exception => e
    raise e unless ENV['RAILS_ENV'] == 'production'
    Notifier::deliver_error_message(e,
                                    clean_backtrace(e),
                                    session.instance_variable_get("@data"),
                                    params,
                                    request.env)
    if request.xhr?
      render_text('<div class="information error">' + ERROR_MESSAGE + '</div>')
    else
      flash.now[:warn] = ERROR_MESSAGE
      redirect_to :action => 'list', :controller => 'bienvenue'
    end
  end

  # met le scope client en session
  # ca permet de ne pas recharger les ids contrats 
  # à chaque fois
  # call it like this : scope_client(params['filters']['client_id'])
  def scope_client(value)
    if value == '' 
      nil 
    else
      conditions = { :client_id => value.to_i }
      options = { :select => 'id', :conditions => conditions }
      Contrat.find(:all, options).collect{|c| c.id}
    end
  end



end
