require 'initializer'
require 'tosca/extension_loader'

module Tosca

  class Configuration < Rails::Configuration
    attr_accessor :extension_paths
    attr_accessor :extensions

    def initialize
      self.extension_paths = default_extension_path
      self.extensions = [ :all ]
      super
    end

    def default_extension_path
      RAILS_ROOT + '/vendor/extensions'
    end
  end

  class Initializer < Rails::Initializer
    def self.run(command = :process, configuration = Configuration.new)
      super
    end

    def set_autoload_paths
      extension_loader.add_extension_paths
      super
    end

    def add_plugin_load_paths
      # checks for plugins within extensions:
      extension_loader.add_plugin_paths
      super
    end

    def load_plugins
      super
      extension_loader.load_extensions
    end

    def after_initialize
      super
      require 'tosca/extension_routes'
      extension_loader.activate_extensions
    end

    def initialize_framework_views
      view_paths = returning [] do |arr|
        # Add the singular view path if it's not in the list
        arr << configuration.view_path
        # Add the extension view paths
        arr.concat extension_loader.view_paths
        # Reverse the list so extensions come first
        arr.reverse!
      end
      if configuration.frameworks.include?(:action_mailer)
        ActionMailer::Base.template_root ||= configuration.view_path
      end
      if configuration.frameworks.include?(:action_controller)
        ActionController::Base.view_paths = view_paths
      end
    end

    def initialize_routing
      extension_loader.add_controller_paths
      super
    end

    def extension_loader
      ExtensionLoader.instance {|l| l.initializer = self }
    end
  end

end
