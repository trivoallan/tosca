#
# Copyright (c) 2006-2009 Linagora
#
# This file is part of Tosca
#
# Tosca is free software, you can redistribute it and/or modify
# it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
# Tosca is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# General controller for the application
# The filters added here are loaded for the others controllers
# All the methods from here are available everywhere

# Authentification
require_dependency 'login_system'

# Manage roles and permissions
# Infos : http://wiki.rubyonrails.com/rails/pages/LoginGeneratorACLSystem/
require_dependency 'acl_system'
require 'overrides'

class ApplicationController < ActionController::Base
  # access protected everywhere, See
  # * Wiki for more generic Info,
  # * lib/scope.rb for deep protection
  # * lib/login_system.rb for account protection
  before_filter :set_gettext_locale, :set_global_shortcuts, :login_required, :before_scope
  after_filter :after_scope

  # Limited perimeter for specific roles
  # around_filter :scope

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

  def set_gettext_locale
    FastGettext.text_domain = 'tosca'
    FastGettext.available_locales = ['en','fr'] #all you want to allow
    super
  end

  # global variables (not pretty, but those two are really usefull)
  @@first_time = true
  def set_global_shortcuts
    # this small hack allows to initialize the static url
    # generator on the first request. We need it 'coz the prefix
    # (e.g.: /tosca) cannot be known before a request go through.
    if @@first_time
      require 'static'
      require 'static_script'
      require 'static_picture'
      Static::ActionView.set_url_root

      #Used for url in e-mails
      ActionMailer::Base.default_url_options[:host] = request.host_with_port
      @@first_time = false
    end
    # useful variable : allows to test both if one is logged & get is account
    @session_user = session[:user]
    true
  end

  def before_scope()
    set_scopes(@session_user)
  end

  def after_scope()
    remove_scopes(@session_user)
  end


  #Compute the receiver of an email for the flash
  def message_notice(recipients, cc)
    result = '<br />' << _("An e-mail was sent to ") << " <b>#{html2text(recipients)}</b> "
    result << '<br />' << _("with a copy to") << " <b>#{html2text(cc)}</b>" if cc && !cc.blank?
    result << '.'
  end

private

  # This array contains all errors that we want to rescue nicely
  # It's mainly for search engine bots, which seems to love
  # hammering wrong address
  def rescue_action_in_public(exception)
    @@rescued_errors ||= [ ActiveRecord::RecordNotFound,
                           ActionController::RoutingError ]
    msg = nil
    @@rescued_errors.each{ |k| if exception.is_a? k
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
