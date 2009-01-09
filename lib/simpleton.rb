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
module Simpleton

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    def instance(&block)
      @instance ||= new
      block.call(@instance) if block_given?
      @instance
    end

    def method_missing(method, *args, &block)
      instance.respond_to?(method) ? instance.send(method, *args, &block) : super
    end

  end

end
