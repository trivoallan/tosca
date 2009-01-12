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
class LoadSkills < ActiveRecord::Migration
  class Competence < ActiveRecord::Base; end

  def self.up
    # Do not erase existing Knowledges
    return unless Competence.count == 0

    # All knowledges, severely reduced to an human size
    [ 'Admin / Réseau', 'Admin / Système', 'Annuaires', 'C / C++',
      'C# / Mono', 'Gestion', 'Java / J2ee', 'OpenOffice', 'Perl',
      'Php', 'Python', 'Ruby', 'SGBD / SQL', 'Web' ].each { |c|
      Competence.create(:nom => c)
    }
  end

  def self.down
    Competence.all.each{ |c| c.destroy }
  end
end
