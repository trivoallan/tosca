#
# Copyright (c) 2006-2008 Linagora
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
# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.1.1' unless defined? RAILS_GEM_VERSION
$KCODE='u'
require 'jcode'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

# Needed for checking missing files
require 'utils'

path = File.join RAILS_ROOT, 'config', 'database.yml'
Utils.check_files(path, 'Your database is not configured')
path = File.join RAILS_ROOT, 'config', 'config.rb'
Utils.check_files(path, 'The configuration of the application is not done')

cache_path = File.join RAILS_ROOT, 'tmp', 'cache'
page_cache_path = File.join RAILS_ROOT, 'public', 'cache'

# Used to have extension
# See http://github.com/pivotal/desert/tree/master for more info
begin
  require 'desert'
rescue
  # It cannot be loaded in config.gem, so we need this hack for freezed version
  desert_path = File.join(RAILS_ROOT, 'vendor', 'gems', 'desert-0.3.2', 'lib')
  $LOAD_PATH.unshift desert_path
  require 'desert'
end

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here

  # Skip frameworks you're not going to use
  config.frameworks -= [ :action_web_service ] # , :action_mailer ]

  # Extension are like rails plugins
  config.plugin_paths += %W( #{RAILS_ROOT}/vendor/extensions )

  # Sweepers are used to cleanup cache nicely
  config.load_paths += %W( #{RAILS_ROOT}/app/sweepers )

  # Distinguish cache from normal pages
  config.action_controller.page_cache_directory = page_cache_path

  ### External libs ###
  # Used to i18n and l10n
  config.gem 'gettext', :lib => 'gettext/rails'
  config.gem 'gettext', :lib => 'gettext/utils' # needed by gettext_localize
  
  # Used to generate graphs of activity report & resize some pictures
  # We keep 1.15.10 version, coz debian makes an old & staging distribution
  # config.gem 'rmagick', :version => '1.15.15', :lib => "RMagick"
  # Used to load the extension mechanism
  config.gem 'desert', :version => '0.3.2'

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the file store with a custom storage path (if the directory doesn’t already exist it will be created)
  config.cache_store = :file_store, cache_path

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

# MLO : Type of cache. See http://api.rubyonrails.org/classes/ActionController/Caching.html
ActionController::Base.cache_store = :file_store, cache_path


# MLO : session duration is one month,
CGI::Session.expire_after 1.month

# MLO : It's faster to use X-Send-File module of Apache
XSendFile::Plugin.replace_send_file! if RAILS_ENV == 'production'

# Config file, mainly use for mail server
require 'config'

# Extensions to String Class
# TODO : make an extension loader, which loads automatically all _extensions.rb
# files
require 'string_extensions'

# Internal libs, located in lib/
require 'overrides'


# Check and create used dirs, which are not on the SCM
log_path = File.join RAILS_ROOT, 'log'
paths = [ log_path, page_cache_path, cache_path ]
paths.each { |path| FileUtils.mkdir_p(path) unless File.exists? path }

# French TimeZone, mandatory coz' of debian nerds :/
ENV['TZ'] = 'Europe/Paris'

# Mime type needed for ods export with Ruport lib
# See app/controller/export_controller.rb
Mime::Type.register "application/vnd.oasis.opendocument.spreadsheet", :ods

# Neeeded for making password, in other things
srand

# Boot Check
path = File.join RAILS_ROOT, "locale", "fr", "LC_MESSAGES", "tosca.mo"
unless File.exists? path
  puts "***********************"
  puts "Missing traducted files. I am generating it for you with "
  puts "$ rake l10n:mo"
  %x[#{"rake l10n:mo"}]
  puts "***********************"
end

# Default conf for gettextlocalize, used for Dates & Currency
if defined? GettextLocalize
  GettextLocalize::app_name = App::Name
  GettextLocalize::app_version = App::Version
  GettextLocalize::default_locale = 'en_US'
  GettextLocalize::default_methods = [:param, :header, :session]
end
