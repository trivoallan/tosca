
# Controller general de l'application
# Les filtres ajoutés à ce controller seront chargés pour tous les autres.
# De même, toutes les méthodes ajoutées ici seront disponibles.

# authentification
require_dependency 'login_system'
# gestion des roles et des permissions
# Infos : http://wiki.rubyonrails.com/rails/pages/LoginGeneratorACLSystem/
require_dependency 'acl_system'
#Scope
require_dependency 'scope_system'

class ApplicationController < ActionController::Base
  init_gettext 'tosca'

  # access protected everywhere, See Wiki for more Info
  before_filter :set_global_shortcuts, :login_required

  # périmètre limité pour certains profils
  around_filter :scope

  # in order to escape conflict with other rails app
  session :session_key => '_tosca_session_id'

  # systems d'authentification
  include ACLSystem
  # système de construction des filters
  include Filters
  # Scope module
  include Scope

  # layout standard
  layout "standard-layout"

  # Options pour tiny_mce
  # http://wiki.moxiecode.com/index.php/TinyMCE:Configuration


protected
  # a small wrapper used in some controller to redirect to homepage,
  # in case of errors : when we cannot know where to redirect
  # TODO : find a faster solution, like overloading redirect_to ?
  def redirect_to_home
    if request.xhr?
      render_text('<div class="information error">' + ERROR_MESSAGE + '</div>')
    else
      redirect_back_or_default bienvenue_path
    end
  end

  # Redirect back or default, if we can find it
  def redirect_back
    session[:return_to] ||= request.env['HTTP_REFERER']
    redirect_back_or_default bienvenue_path
  end

  # global variables (not pretty, but those two are really usefull)
  @@first_time = true
  def set_global_shortcuts
    # this small hack allows to initialize the static url
    # generator on the first request. We need it 'coz the prefix
    # (e.g.: /tosca) cannot be known before a request go through.
    if @@first_time and not defined? Static
      require 'static'
      require 'static_script'
      require 'static_image'
      Static::ActionView.set_request(request())
      @@first_time = false
    end
    #    /!\
    # don't forget to take a look at accout/clear_session method
    # if you add something here. And don't add something here too ;).
    #    /!\
    user = session[:user]
    if user
      @ingenieur = user.ingenieur
      @beneficiaire = user.beneficiaire
    end
    true
  end

  def scope(&block)
    is_connected = session.data.has_key? :user
    user = session[:user]
    define_scope(user, is_connected, &block)
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

  # TODO : put it elsewhere and not in a constant : it needs to be localisable
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
      redirect_to(bienvenue_path, :status => :moved_permanently)
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
