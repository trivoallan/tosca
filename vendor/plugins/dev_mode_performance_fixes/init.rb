# these hacks are only for faster development
if RAILS_ENV=="development"
# we need to load the rails dispatcher because normally it's not loaded so early
  require 'action_controller/dispatcher'
  require 'dispatcher_hacks'
  ActionController::Dispatcher.send :include, DispatcherHacks
  ActionController::Dispatcher.send :before_dispatch, :reset_application

  require 'dependencies'
  # this patch has already made it into Rails edge for 2.0
  require 'routing_patches'
end
