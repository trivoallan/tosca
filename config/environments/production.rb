# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
=begin
  Deactivated for now : we have on welcome;admin
 * 15 r/s with it
 * 80 r/s without it
# require 'hodel_3000_compliant_logger'
# config.logger = nil
# RAILS_DEFAULT_LOGGER = Hodel3000CompliantLogger.new(config.log_path)
=end

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

config.log_level = :info

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host = "http://assets.example.com"

# Disable delivery errors if you bad email addresses should just be ignored
config.action_mailer.raise_delivery_errors = false

# View Optimization : no '\n'
ActionView::Base.erb_trim_mode = '>'
