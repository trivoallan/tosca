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
class LoadArchs < ActiveRecord::Migration
  class Arch < ActiveRecord::Base; end

  def self.up
    # Do not erase existing Arches
    return unless Arch.count == 0

    # Binary packages known architectures
    %w(noarch all ppc sparc32 sparc64 i386 i586 i686 x86_64).each { |a|
      Arch.create(:nom => a)
    }
  end

  def self.down
    Arch.destroy_all
  end
end
