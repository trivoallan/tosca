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
class LoadContributionState < ActiveRecord::Migration
  class Etatreversement < ActiveRecord::Base; end

  def self.up
    # Do not erase existing states
    return unless Etatreversement.count == 0

    # Known state for a contribution
    Etatreversement.create(:nom => 'rejetée', :description =>
                           'Correctif soumis mais non accepté par la communauté.')
    Etatreversement.create(:nom => 'non reversée', :description =>
                           "Ce correctif n'est pas reversé à la communauté. C'est souvent le cas des backport.")
    Etatreversement.create(:nom => 'acceptée', :description =>
                           'Correctif accepté dans la branche principale du projet.')
    Etatreversement.create(:nom => 'proposée', :description =>
                           "Échanges en cours pour déterminer les modalités d'intégration du correctif.")
  end

  def self.down
    Etatreversement.all.each{ |er| er.destroy }
  end
end
