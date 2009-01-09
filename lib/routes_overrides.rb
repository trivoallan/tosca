#
# Copyright (c) 2006-2009 Linagora
#
# This file is part of Tosca
#
# Tosca is free software, you can redistribute it and/or modify
# it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
# Tosca is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# This module is overloaded in order to have rails fitting more
# Tosca specific needs or specific improvments
#
# It's not in the main 'overrides' file since rails code for routes
# are loaded differently in production mode. So :
# /!\ Do NOT merge overrides with overrides_routes /!\
#

module MapperExtension
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

ActionController::Routing::RouteSet::Mapper.send :include, MapperExtension

class ActionController::Routing::RouteSet::NamedRouteCollection
  # This override allows to return a nil url in case of an
  # authenticated user without any right to the page
  def define_url_helper(route, name, kind, options)
    selector = url_helper_name(name, kind)

    hash_access_method = hash_access_name(name, kind)
    # allow ordered parameters to be associated with corresponding
    # dynamic segments, so you can do
    #
    #   foo_url(bar, baz, bang)
    #
    # instead of
    #
    #   foo_url(:bar => bar, :baz => baz, :bang => bang)
    #
    # Also allow options hash, so you can do
    #
    #   foo_url(bar, baz, bang, :sort_by => 'baz')
    #
    @module.module_eval <<-end_eval #We use module_eval to avoid leaks
      def #{selector}(*args)
        # See lib/{acl_system,overrides}.rb for implementation
        return nil unless authorize_url?(#{route.defaults.inspect})

        #{generate_optimisation_block(route, kind)}

        opts = if args.empty? || Hash === args.first
          args.first || {}
        else
          options = args.last.is_a?(Hash) ? args.pop : {}
          args = args.zip(#{route.segment_keys.inspect}).inject({}) do |h, (v, k)|
            h[k] = v
            h
          end
          options.merge(args)
        end

        url_for(#{hash_access_method}(opts))
      end
      protected :#{selector}
    end_eval
    helpers << selector
  end
end
