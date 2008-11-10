if config.frameworks.include? :action_controller
  ActionController::Base.send :include, AutoComplete
  ActionController::Base.helper AutoCompleteMacrosHelper
end
