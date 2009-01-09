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
module Annotatable

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def self.extended(base)
      base.instance_eval do
        alias :inherited_without_annotatable :inherited
        alias :inherited :inherited_with_annotatable
      end
    end

    def annotate(*attrs)
      options = {}
      options = attrs.pop if attrs.last.kind_of?(Hash)
      options.symbolize_keys!
      inherit = options[:inherit]
      if inherit
        @inherited_annotations ||= []
        @inherited_annotations += attrs
      end
      attrs.each do |attr|
        class_eval %{
          def self.#{attr}(string = nil)
            @#{attr} = string || @#{attr}
          end
          def #{attr}(string = nil)
            self.class.#{attr}(string)
          end
          def self.#{attr}=(string = nil)
            #{attr}(string)
          end
          def #{attr}=(string = nil)
            self.class.#{attr}=(string)
          end
        }
      end
      attrs
    end

    def inherited_with_annotatable(subclass)
      inherited_without_annotatable(subclass)
      (["inherited_annotations"] + (@inherited_annotations || [])).each do |t|
        ivar = "@#{t}"
        subclass.instance_variable_set(ivar, instance_variable_get(ivar))
      end
    end
  end

end

# We don't necessarily have ActiveSupport loaded yet!
class Hash
  # Return a new hash with all keys converted to symbols.
  def symbolize_keys
    inject({}) do |options, (key, value)|
      options[key.to_sym || key] = value
      options
    end
  end

  # Destructively convert all keys to symbols.
  def symbolize_keys!
    self.replace(self.symbolize_keys)
  end
end
