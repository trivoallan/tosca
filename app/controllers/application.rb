#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################

# Controller general de l'application
# Les filtres ajoutés à ce controller seront chargés pour tous les autres.
# De même, toutes les méthodes ajoutées ici seront disponibles.

# authentification
require_dependency 'login_system'
# gestion des roles et des permissions
# Infos : http://wiki.rubyonrails.com/rails/pages/LoginGeneratorACLSystem/
require_dependency 'acl_system'
require_dependency 'filters'
require_dependency 'lstm'

class ApplicationController < ActionController::Base
  # accès protégé et standardisé
  before_filter :set_global_shortcuts
  before_filter :login_required, :except => [:refuse, :login]

  # périmètre limité pour certains profils
  around_filter :scope

  # systems d'authentification 
  include LoginSystem
  include ACLSystem
  # système de construction des filters
  include Filters
  include Lstm

  # layout standard
  layout "standard-layout"

  # Options pour tiny_mce
  # http://wiki.moxiecode.com/index.php/TinyMCE:Configuration
  uses_tiny_mce :options => { :mode => 'textareas',
                              :theme => 'advanced',
                              :browsers => %w{msie gecko opera},
                              :theme_advanced_toolbar_location => "top",
                              :theme_advanced_toolbar_align => "left",
                              :paste_auto_cleanup_on_paste => true,
                              :theme_advanced_buttons1 => %w{formatselect fontselect fontsizeselect bold
                                                             italic underline strikethrough},
                              :theme_advanced_buttons2 => %w{justifyleft justifycenter justifyright indent outdent separator
                                                             bullist numlist forecolor backcolor separator link
                                                             unlink image undo redo separator emotions code},
                              :theme_advanced_buttons3 => [],
                              :plugins => %w{contextmenu paste emotions},
                              :language => 'fr',
                              :editor_deselector => 'mceNoEditor' }


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
  SCOPE_CLIENT = [ Client, Demande, Document, Socle ]
  SCOPE_CONTRAT = [ Binaire, Contrat, Contribution, Logiciel, Paquet ] 
  # Cette fonction intègre un scope "maison", beaucoup plus rapide.
  # Il reste néanmoins intégralement safe
  # Le but est d'éviter les 15 imbrications de yield, trop couteuses
  def scope
    beneficiaire = session[:beneficiaire]
    ingenieur = session[:ingenieur]
    client_ids, contrat_ids = nil, nil
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
      SCOPE_CLIENT.each { |m| m.remove_scope() } if client_ids
      SCOPE_CONTRAT.each { |m| m.remove_scope() } if contrat_ids
    end
  end

  ERROR_MESSAGE = 'Une erreur est survenue. Notre service a été prévenu' + 
    ' et dispose des informations nécessaires pour corriger.<br />' +
    'N\'hésitez pas à nous contacter si le problème persiste.' 
  WARN_NOID = 'Veuillez préciser une adresse existante et valide. Nous ne ' + 
    'considérons pas que c\'est une erreur. Si vous pensez le contraire, ' + 
    'n\'hésitez pas à nous contacter.' 
  def rescue_action_in_public(exception)
    if exception.is_a? ActiveRecord::RecordNotFound
      msg = WARN_NOID
    else
      msg = ERROR_MESSAGE
      if ENV['RAILS_ENV'] == 'production'
        Notifier::deliver_error_message(exception, clean_backtrace(exception),
                                        session.instance_variable_get("@data"),
                                        params, request.env)
      end
    end
    if request.xhr?
      render_text('<div class="information error">' + msg + '</div>')
    else
      flash[:warn] = msg
      redirect_to :action => 'list', :controller => 'bienvenue'
    end

  end
  

  # met le scope client en session
  # ca permet de ne pas recharger les ids contrats 
  # à chaque fois
  # call it like this : scope_client(params['filters']['client_id'])
  # TODO : virer cette horreur
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
