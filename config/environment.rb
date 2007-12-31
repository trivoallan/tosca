#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.0.2'
$KCODE='u'
require 'jcode'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here

  # Skip frameworks you're not going to use
  config.frameworks -= [ :action_web_service ] # , :action_mailer ]

  # Add additional load paths for your own custom dirs
  config.load_paths += %W( #{RAILS_ROOT}/app/sweepers )

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

  # Some plugins needs to be loaded after rails
  config.after_initialize do
    # Used to generate Ods Export. See ExportController.
    require "ruport"
    require 'ruport/util'
  end
  # See Rails::Configuration for more options
end

# MLO : sql session store, 1.5x times faster than Active record store
ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS.
  update(:database_manager => SqlSessionStore)
SqlSessionStore.session_class = MysqlSession

# MLO : session duration is one month,
CGI::Session.expire_after 1.month

# MLO : It's faster to use X-Send-File module of Apache
XSendFile::Plugin.replace_send_file! if RAILS_ENV == 'production'

# Internal libs, located in lib/
require 'utils'
require 'config'
require 'overrides'
require 'extract'

# External libs

# Used to load gettext 4 rails and to localize Dates & Number
 require 'gettext_localize'
 require 'gettext_localize_rails'

# Used to have cool preview with attachments
 require 'uv'

# Used to generated OpenDocument file.
 require 'filters'
 require 'zip/zip'

#French TimeZone, mandatory coz' of debian nerds :/
ENV['TZ'] = 'Europe/Paris'

# Mime type needed for ods export with Ruport lib
# See app/controller/export_controller.rb
Mime::Type.register "application/vnd.oasis.opendocument.spreadsheet", :ods

# Boot Check
unless File.exists?(File.expand_path("locale/fr/LC_MESSAGES/lstm.mo",
                                     RAILS_ROOT))
  puts "***********************"
  puts "Missing traducted files. I am generating it for you with "
  puts "$ rake makemo"
  %[#{"rake makemo"}]
  puts "***********************"
end


# Default conf for gettextlocalize, used for Dates & Currency
if defined? GettextLocalize
  GettextLocalize::app_name = 'lstm'
  GettextLocalize::app_version = '0.5.3'
  GettextLocalize::default_locale = 'en_US'
  GettextLocalize::default_methods = [:param, :header, :session]
end

# Add new inflection rules using the following format
# (all these examples are active by default):
Inflector.inflections do |inflect|
  inflect.plural(/^(ox)$/i, '\1en')
  inflect.singular(/^(ox)en/i, '\1')
  inflect.irregular 'jourferie', 'jourferies'
  inflect.uncountable %w( fish sheep )
end

# Preload of controllers/models during boot.
if RAILS_ENV == 'production'
  require_dependency 'application'
  Dir.foreach( "#{RAILS_ROOT}/app/models" ) { |f|
    silence_warnings{require_dependency f
    } if f =~ /\.rb$/}
  Dir.foreach( "#{RAILS_ROOT}/app/controllers" ) { |f|
    silence_warnings{require_dependency f
    } if f =~ /\.rb$/}
end
