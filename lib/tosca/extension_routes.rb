module Tosca
  module Routes

    def self.included(base)
      base.class_eval do
        alias :draw_without_plugin_routes :draw
        alias :draw :draw_with_plugin_routes
      end
    end

    def draw_with_plugin_routes
      draw_without_plugin_routes do |mapper|
        add_extension_routes(mapper)
        yield mapper
      end
    end

    private

      def add_extension_routes(mapper)
        subclasses_of(Extension).each do |ext|
          ext.route_definitions.each do |block|
            block.call(mapper)
          end
        end
      end

  end
end

ActionController::Routing::RouteSet.class_eval { include Tosca::Routes }
