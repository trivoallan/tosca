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

  def set_headers
    headers['Content-Type'] =
      ( request.xhr? ? 'text/javascript; charset=utf-8' : 
        'text/html; charset=utf-8' )
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
    scope_beneficiaire {
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


private
  # scope imposé sur toutes les vues, 
  # pour limiter ce que peuvent voir nos clients
  ERROR_MESSAGE = 'Une erreur est survenue. Notre service a été prévenu' + 
    ' et dispose des informations nécessaire pour corriger.<br />' +
    'N\'hésitez pas à nous contacter si le problème persiste.' 
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
