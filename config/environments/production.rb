#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
require 'hodel_3000_compliant_logger'
config.logger = nil 
RAILS_DEFAULT_LOGGER = Hodel3000CompliantLogger.new(config.log_path)

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# require 'hodel_3000_compliant_logger'
# config.logger = Hodel3000CompliantLogger.new(config.log_path)

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors if you bad email addresses should just be ignored
config.action_mailer.raise_delivery_errors = false


