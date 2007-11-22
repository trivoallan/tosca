#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################


# This module is overloaded in order to have rails fitting more
# Tosca specific needs or specific improvments
#
# It's not in the main 'overrides' file since rails code for routes
# are loaded differently in production mode. So :
# /!\ Do NOT merge overrides with overrides_routes /!\
#
module ActionController::Routing
  class RouteSet
    # this overloads allows to have REST routes for non-orm controllers
    class Mapper
      # Mapper for non-resource controller
      def without_orm(controller, actions, method = :get)
        actions.each { |action|
          if action != 'index'
            self.send("#{action}_#{controller}", "#{controller}/#{action}",
                      { :controller => controller, :action => action,
                        :conditions => { :method => method }})
          else
            self.send("#{controller}", "#{controller}",
                      { :controller => controller, :action => action,
                        :conditions => { :method => :get }})
          end
        }
      end

      # Mapper for exporting with format, done in a special controller 'export'.
      def formatted_export(actions)
        actions.each { |action|
          self.send('named_route', "formatted_#{action}_export", "export/#{action}.:format",
                    { :controller => 'export', :action => action,
                      :conditions => { :method => :get }})
        }
      end
    end


    class NamedRouteCollection
      # This overload permits to gain a factor 7 in performance of
      # url generation
      # This allows too to return a nil url in case of an
      # authenticated user without any right to the page
      def define_url_helper(route, name, kind, options)
        selector = url_helper_name(name, kind)

        # The segment keys used for positional paramters
        segment_keys = route.segments.collect do |segment|
          segment.key if segment.respond_to? :key
        end.compact
        hash_access_method = hash_access_name(name, kind)

        @module.send :module_eval, <<-end_eval #We use module_eval to avoid leaks
          def #{selector}(*args)
            opts = if args.empty? || Hash === args.first
              args.first || {}
            else
              # allow ordered parameters to be associated with corresponding
              # dynamic segments, so you can do
              #
              #   foo_url(bar, baz, bang)
              #
              # instead of
              #
              #   foo_url(:bar => bar, :baz => baz, :bang => bang)
              args.zip(#{segment_keys.inspect}).inject({}) do |h, (v, k)|
                h[k] = v
                h
              end
            end
            # return a cached version of the url for the default one
            url_options = #{hash_access_method}(opts)
            required_perm = '%s/%s' % [ url_options[:controller], url_options[:action] ]
            user = session[:user]
            if user and not user.authorized? required_perm
              nil
            else
              if opts.empty?
                @@#{selector}_cache ||= url_for(url_options)
              else
                url_for(url_options)
              end
            end
          end
        end_eval
        @module.send(:protected, selector)
        helpers << selector
      end
    end # NamedRouteCollection
  end # RouteSet
end
