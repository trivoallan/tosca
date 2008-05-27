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



