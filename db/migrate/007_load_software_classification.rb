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
class LoadSoftwareClassification < ActiveRecord::Migration
  class Groupe < ActiveRecord::Base; end

  def self.up
    # Do not erase existing Groups
    return unless Groupe.count == 0

    # Common classification for open source projects
    %w(Administration Bureautique Collaboratif Exploitation Frameworks
       Infrastructure Langage Messagerie Portail Publication Réseau
       Sécurité Serveur SGBD SIG Supervision Systeme Test).each{|g|
      Groupe.create(:nom => g)
    }
  end

  def self.down
    Groupe.all.each{ |g| g.destroy }
  end
end
