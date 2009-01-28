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
class ApplicationControllerTest < ActionController::TestCase

  #We generate one method by test
  self.instance_eval do
    routes = ActionController::Routing::Routes.routes

    #We load all the controllers
    Dir.glob(RAILS_ROOT + '/app/controller/*.rb').each { |file| require file }
    controllers = Object.subclasses_of(ActionController::Base).map(&:to_s)

    Permission.all.each do |p|
      perm = Regexp.compile(p.name)

      routes.each do |r|
        #string of the rout ex : account/login
        string_route = r.segments.to_s
        if perm.match(string_route) and 
            ((r.conditions.has_key? :method and r.conditions[:method] == :get) or #only GET routes
              r.conditions.empty?)

          p.roles.each do |role|

            #We define one method for each test, it is easier to debug
            define_method("test_#{string_route}_#{p.name}_#{role.name}") do
              #login has user
              login role.name, role.name

              #Find the controller
              possible_controllers = controllers.grep(Regexp.compile(r.requirements[:controller], Regexp::IGNORECASE))
              unless possible_controllers.empty?
                #Set the controller
                @controller = eval(possible_controllers.first + ".new")
                #Get the action
                get r.requirements[:action], :id => 1 #We specifiy id = 1 for all views like edit/show
                assert_response :success
              end
            end
            
          end
        end
      end
    end
  end
  
end
