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
class Module
  def include_all_modules_from(parent_module)
    parent_module.constants.each do |const|
      mod = parent_module.const_get(const)
      if mod.class == Module && !defined? mod
        send(:include, mod)
        include_all_modules_from(mod)
      end
    end
  end
end

def helper(*helper_names)
  returning @helper_proxy ||= Object.new do |helper|
    helper_names.each { |h| helper.extend "#{h}_helper".classify.constantize }
  end
end

require 'application'

class << helper
  include_all_modules_from ActionView
end

@controller = ApplicationController.new
helper :application rescue nil
