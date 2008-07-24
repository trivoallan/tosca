# General controller for the application
# The filters added here are loaded for the others controllers
# All the methods from here are available everywhere

# Authentification
require_dependency 'login_system'

# Manage roles and permissions
# Infos : http://wiki.rubyonrails.com/rails/pages/LoginGeneratorACLSystem/
require_dependency 'acl_system'

#Scope
require_dependency 'scope_system'

class ApplicationController < ActionController::Base
  init_gettext 'tosca'

  # access protected everywhere, See Wiki for more Info
  before_filter :set_global_shortcuts, :login_required

  # Limited perimeter for specific roles
  around_filter :scope

  # In order to escape conflict with other rails app
  session :session_key => '_tosca_session_id'

  # Authentification system
  include ACLSystem

  # System for building filters
  include Filters

  # Scope module
  include Scope

  # Standard layout
  layout "standard-layout"

  # Options for tiny_mce
  # http://wiki.moxiecode.com/index.php/TinyMCE:Configuration

protected
  # a small wrapper used in some controller to redirect to homepage,
  # in case of errors : when we cannot know where to redirect
  # TODO : find a faster solution, like overloading redirect_to ?
  def redirect_to_home
    if request.xhr?
      render :text => ('<div class="information error">' + ERROR_MESSAGE + '</div>')
    else
      redirect_back_or_default welcome_path
    end
  end

  # Redirect back or default, if we can find it
  def redirect_back
    session[:return_to] ||= request.env['HTTP_REFERER']
    redirect_back_or_default welcome_path
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

  # Todo : Why is there 2 times the same information in args of define_scope ???
  def scope(&block)
    user = session[:user]
    is_connected = !user.nil?
    define_scope(user, is_connected, &block)
  end

private

  # This array contains all errors that we want to rescue nicely
  # It's mainly for search engine bots, which seems to love
  # hammering wrong address
  RescuedErrors =
    [ ActiveRecord::RecordNotFound, ActionController::RoutingError
    ] unless defined? RescuedErrors

  def rescue_action_in_public(exception)
    msg = nil
    RescuedErrors.each{ |k| if exception.is_a? k
        msg = _('This address is not valid. If you think this is an error, do not hesitate to contact us.')
      end
    }
    if msg.nil?
      msg = _('An error has occured. We are now advised of your issue and have all the required information to investigate in order to fix it.') +
        '<br />' + _('Please contact us if your problem remains.')
      if ENV['RAILS_ENV'] == 'production'
        Notifier::deliver_error_message(exception, clean_backtrace(exception),
                                        session.instance_variable_get("@data"),
                                        params, request.env)
      end
    end

    if request.xhr?
      render :text => ('<div class="information error">' + msg + '</div>')
    else
      flash[:warn] = msg
      redirect_to(welcome_path, :status => :moved_permanently)
    end

  end

end
