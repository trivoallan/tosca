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
require File.dirname(__FILE__) + '/../test_helper'

# Each Controller Test should test all _public_ methods
# This test generate one method by route / role combination
class ApplicationControllerTest < ActionController::TestCase

  self.instance_eval do
    routes = ActionController::Routing::Routes.routes

    # This pre-load is required to obtain controllers and models list
    Dir.glob(RAILS_ROOT + '/app/controllers/*.rb').each { |file| require file }
    controllers = Object.subclasses_of(ActionController::Base).map(&:to_s)
    Dir.glob(RAILS_ROOT + '/app/models/*.rb').each { |file| require file }
    models = Object.subclasses_of(ActiveRecord::Base).map(&:to_s)


    Permission.all.each do |p|
      perm = Regexp.compile(p.name)

      routes.each do |r|
        # string of the rout ex : account/login
        string_route = r.segments.to_s
        # Only display is tested and not a ajax view
        next unless perm.match(string_route) and
          (r.conditions.empty? or
            (r.conditions[:method] == :get)) and 
          not r.requirements[:action] =~ /^ajax/

        p.roles.each do |role|
          # We define one method for each test, it is easier to debug
          define_method("test '#{string_route}' on (#{p.name}) with '#{role.name}'") do
            login role.name, role.name
            possible_controllers = controllers.grep(/#{r.requirements[:controller]}/i)
            next if possible_controllers.empty?
            # Needed to access to the page
            @controller = eval(possible_controllers.first + ".new")

            possible_models = models.grep(/^#{r.requirements[:controller].singularize}$/i)
            id = 1
            id = eval(possible_models.first + ".first.id") unless possible_models.empty?
            
            # We specifiy an id for all views like edit/show.
            # It does not impact generic views
            get r.requirements[:action], :id => id
            assert_response :success
          end
        end
      end
    end
  end

end
