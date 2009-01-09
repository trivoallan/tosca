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
#!/usr/bin/env ruby
require "config/environment"
Dir.glob("app/models/*rb") { |f|
    require f
}
puts "digraph x {"
Dir.glob("app/models/*rb") { |f|
    f.match(/\/([a-z_]+).rb/)
    classname = $1.camelize
    klass = Kernel.const_get classname
    if klass.superclass == ActiveRecord::Base
        puts classname
        klass.reflect_on_all_associations.each { |a|
      case a.macro.to_s
      when 'belongs_to' then
          puts classname + " -> " + a.name.to_s.camelize.singularize + " [arrowhead=inv]"
      when 'has_many' then
          puts classname + " -> " + a.name.to_s.camelize.singularize + " [arrowhead=crow]"
      when 'has_one' then
          puts classname + " -> " + a.name.to_s.camelize.singularize + " [arrowhead=inv]"
      when 'has_and_belongs_to_many' then
          puts classname + " -> " + a.name.to_s.camelize.singularize + 
          " [arrowhead=crow,arrowtail=crow,dir=both]"
      else 
        puts a.macro.to_s
      end

        }
    end
}
puts "}"



