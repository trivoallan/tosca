# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false
config.action_view.debug_rjs                         = true

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

# Used to shut up warning about "already defined constant ..."
Dependencies.explicitly_unloadable_constants =
  %w(Struct::Knowledges Struct::Contributions Struct::Software Struct::Calls
     Struct::Clients Struct::Requests Struct::Accounts
     Scope::SCOPE_CLIENT Scope::SCOPE_CONTRACT
     Demande::TERMINEES Demande::EN_COURS
     Demande::SELECT_LIST DEMANDE::JOINS_LIST)
