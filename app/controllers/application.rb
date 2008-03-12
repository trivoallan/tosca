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

class ApplicationController < ActionController::Base
  init_gettext 'tosca'

  # accès protégé et standardisé
  before_filter :login_required, :set_global_shortcuts

  # périmètre limité pour certains profils
  around_filter :scope

  # in order to escape conflict with other rails app
  session :session_key => '_tosca_session_id'

  # systems d'authentification
  include ACLSystem
  # système de construction des filters
  include Filters

  # layout standard
  layout "standard-layout"

  # Options pour tiny_mce
  # http://wiki.moxiecode.com/index.php/TinyMCE:Configuration
  # L'option pour ne pas avoir de tinyMCE est la class "mceNoEditor".
  # TODO : mettre le bouton "image" et le plugin "advimage", quand on aura
  # fini la vue sur l'upload
  TINY_BUTTONS = %w(formatselect bold italic underline strikethrough separator
                    bullist numlist forecolor separator link unlink separator
                    undo redo separator code)
  uses_tiny_mce :options => { :mode => 'textareas',
                              :entity_encoding => 'raw',
                              :relative_urls => false,
                              :remove_script_host => false,
                              :theme => 'advanced',
                              :theme_advanced_toolbar_location => "top",
                              :theme_advanced_toolbar_align => "left",
                              :paste_auto_cleanup_on_paste => true,
                              :theme_advanced_buttons1 => TINY_BUTTONS,
                              :theme_advanced_buttons2 => [],
                              :theme_advanced_buttons3 => [],
                              :plugins => %w{contextmenu paste},
                              :editor_deselector => 'mceNoEditor' }


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
  # There is a global scope, on all finders, in order to
  # preserve each user in his particular space.
  # TODO : scope contract only ?? it seems coherent...
  SCOPE_CLIENT = [ Client, Document, Socle ]
  SCOPE_CONTRAT = [ Binaire, Contrat, Demande, Paquet, Phonecall ]

  # This method has a 'handmade' scope, really faster and with no cost
  # of safety. It was made in order to avoid 15 yields.
  def scope
    is_connected = session.data.has_key? :user
    if is_connected
      user = session[:user]
      beneficiaire, ingenieur = user.beneficiaire, user.ingenieur
      apply = ((ingenieur and user.restricted?) || beneficiaire)
      if apply
        contrat_ids = user.contrat_ids
        client_ids = user.client_ids
        SCOPE_CONTRAT.each {|m| m.set_scope(contrat_ids) }
        SCOPE_CLIENT.each {|m| m.set_scope(client_ids) }
      end
    else
      # Forbid access to request if we are not connected. It's just a paranoia.
      Demande.set_scope([0])
    end
    begin
      yield
    ensure
      if is_connected
        if apply
          SCOPE_CLIENT.each { |m| m.remove_scope }
          SCOPE_CONTRAT.each { |m| m.remove_scope }
        end
      else
        Demande.remove_scope
      end
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
      redirect_to bienvenue_path
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
