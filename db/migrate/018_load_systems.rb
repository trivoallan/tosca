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
class LoadSystems < ActiveRecord::Migration
  class Socle < ActiveRecord::Base; end

  def self.up
    # Do not erase existing system
    return unless Socle.count == 0

    # sample known systems
    [ 'Ubuntu Dapper (6.04)', 'Ubuntu Dapper LTS (6.06)', 'Ubuntu Edgy (6.10)',
      'Ubuntu Feisty (7.04)', 'Ubuntu Gutsy (7.10)',
      'Mandriva Corporate 3', 'Mandriva Corporate 4',
      'Debian Potato (2.0)', 'Debian Sarge (3.0)', 'Debian Etch (4.0)',
      'RHES 3', 'RHEL 4', 'RHES 4',
      'Fedora Core 6', 'Fedora Core 7', 'Fedora 8',
      'Linux', 'Solaris 10', 'AIX',
      'Windows 2k', 'Windows XP', 'Windows Vista' ].each {|s|
      Socle.create(:nom => s)
    }
  end

  def self.down
    Socle.all.each{ |s| s.destroy }
  end
end
