#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
*# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '1.2.2'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require 'overrides'
require 'utils'

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here
  
  # Skip frameworks you're not going to use
  # config.frameworks -= [ :action_web_service, :action_mailer ]

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

require 'config'

#TimeZone française, nécessaire sur ces *hum* de debian
ENV['TZ'] = 'Europe/Paris'

# Add new inflection rules using the following format 
# (all these examples are active by default):
Inflector.inflections do |inflect|
  inflect.plural /^(ox)$/i, '\1en'
  inflect.singular /^(ox)en/i, '\1'
  inflect.irregular 'person', 'people'
  inflect.irregular 'typeanomalie', 'typeanomalies'
  inflect.irregular 'jourferie', 'jourferies'
  inflect.irregular 'tache', 'taches'
  inflect.uncountable %w( fish sheep )
end


#Optimization des vues : plus '\n'
ActionView::Base.erb_trim_mode = '>'




# Rédéfinit globalement en français les messages d'erreur
ActiveRecord::Errors.default_error_messages = {
  :inclusion => "n'est pas inclus dans la liste",
  :exclusion => "est réservé",
  :invalid => "est invalide",
  :confirmation => "ne correspond pas à la confirmation",
  :accepted => "doit être accepté",
  :empty => "ne peut être vide",
  :blank => "ne peut être blanc",
  :too_long => "est trop long (max. %d caractère(s))",
  :too_short => "est trop court (min %d caractère(s))",
  :wrong_length => "a une longueur incorrecte (doit être de %d caractère(s))",
  :taken => "est déjà utilisé",
  :not_a_number => "n'est pas une valeur numérique"
}

# Rédéfinit globalement en français les titres et textes de la boîtes d'erreur
module ActionView::Helpers::ActiveRecordHelper
  def error_messages_for(object_name, options = {:class => 'error'})
    options = options.symbolize_keys
    object = instance_variable_get("@#{object_name}")
    unless object.errors.empty?
      if object.errors.count==1 then
        content_tag("div",
                    content_tag(
                                options[:header_tag] || "h2",
                                "Une erreur a bloqué l'enregistrement de votre #{object_name.to_s.gsub('_', ' ')}"
                                ) +
                                   content_tag("p", "Corriger l'élément suivant pour poursuivre :") +
                                   content_tag("ul", object.errors.full_messages.collect { |msg| content_tag("li", msg) }),
                    "id" => options[:id] || "errorExplanation", "class" => options[:class] || "errorExplanation"
                    )
      else
        content_tag("div",
                    content_tag(
                                options[:header_tag] || "h2",
                                "#{object.errors.count} erreurs ont bloqué l'enregistrement de votre #{object_name.to_s.gsub('_', ' ')}"
                                ) +
                                   content_tag("p", "Corriger les éléments suivants pour poursuivre :") +
                                   content_tag("ul", object.errors.full_messages.collect { |msg| content_tag("li", msg) }),
                    "id" => options[:id] || "errorExplanation", "class" => options[:class] || "errorExplanation"
                    )
      end
    end
  end
end

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
   if session[:user] and session[:user].authorized? required_perm then
     "<a href=\"#{url}\"#{tag_options}>#{name || url}</a>"
   else
     nil
   end
 end
end




