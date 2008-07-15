require 'initializer'
require 'tosca/extension_loader'

module Tosca

  class Configuration < Rails::Configuration
    attr_accessor :extension_paths
    attr_accessor :extensions
    attr_accessor :view_paths

    def initialize
      self.view_paths = []
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
      extension_loader.activate_extensions
    end

    def initialize_framework_views
      view_paths = returning [] do |arr|
        # Add the singular view path if it's not in the list
        arr << configuration.view_path if !configuration.view_paths.include?(configuration.view_path)
        # Add the default view paths
        arr.concat configuration.view_paths
        # Add the extension view paths
        arr.concat extension_loader.view_paths
        # Reverse the list so extensions come first
        arr.reverse!
      end
      if configuration.frameworks.include?(:action_controller) || defined?(ActionController::Base)
        view_paths.each do |vp|
          unless ActionController::Base.view_paths.include?(vp)
            ActionController::Base.prepend_view_path vp
          end
        end
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
