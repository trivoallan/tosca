#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
*# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '1.2.3'
$KCODE='u'
require 'jcode'


# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require 'overrides'
require 'utils'


Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here
  
  # Skip frameworks you're not going to use
  config.frameworks -= [ :action_web_service ] # , :action_mailer ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # See Rails::Configuration for more options
end

# MLO : sql session store, 1.5x times faster than Active record store
ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS.
  update(:database_manager => SqlSessionStore)
SqlSessionStore.session_class = MysqlSession

require 'config'
require 'gettext/rails'

#TimeZone française, nécessaire sur ces barbus trolleurs de debian
ENV['TZ'] = 'Europe/Paris'

# Add new inflection rules using the following format 
# (all these examples are active by default):
Inflector.inflections do |inflect|
  inflect.plural /^(ox)$/i, '\1en'
  inflect.singular /^(ox)en/i, '\1'
  inflect.irregular 'jourferie', 'jourferies'
  inflect.uncountable %w( fish sheep )
end


#Optimization des vues : plus '\n'
ActionView::Base.erb_trim_mode = '>'

#redéfinit l'affichage des urls _uniquement_ si l'utilisateur en a le droit
module ActionView::Helpers::UrlHelper

 def link_to(name, options = {}, html_options = nil, *parameters_for_method_reference)
   if html_options
     html_options = html_options.stringify_keys
     convert_options_to_javascript!(html_options)
     tag_options = tag_options(html_options)
   else
     tag_options = nil
   end
   url = options.is_a?(String) ? options : self.url_for(options, *parameters_for_method_reference)
   required_perm = '%s/%s' % [ options[:controller] || controller.controller_name, 
     options[:action] || controller.action_name ]
   user = session[:user]
   if user and user.authorized? required_perm then
     "<a href=\"#{url}\"#{tag_options}>#{name || url}</a>"
   else
     nil
   end
 end
end
