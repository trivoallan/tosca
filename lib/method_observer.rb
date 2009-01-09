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
class MethodObserver

  attr_reader :target
  attr_accessor :result

  class ObserverCannotObserveTwiceError < StandardError
    def initialize(message = 'observer cannot observe twice')
      super
    end
  end

  def observe(target)
    raise ObserverCannotObserveTwiceError if @target
    @target = target
    make_observable(target)
  end

  def self.instances
    @instances ||= {}
  end

  def self.new(*args)
    o = super
    instances[o.object_id] = o
    o
  end

  private
    def make_observable(target)
      methods_to_observe.each do |method|
        target.instance_eval %{
          def #{method}(*args, &block)
            observer = #{self.class}.instances[#{self.object_id}]
            observer.send(:before_#{method}, *args, &block) if observer.respond_to? :before_#{method}
            observer.result = super
            observer.send(:after_#{method}, *args, &block) if observer.respond_to? :after_#{method}
            observer.result
          end
        }
      end
    end

    def methods_to_observe
      (methods_for(:before) + methods_for(:after)).uniq
    end

    def methods_for(name)
      methods.grep(/^#{name}_/).map { |n| n.to_s.gsub(/^#{name}_/, '').intern }
    end
end
