#
# Copyright (c) 2006-2008 Linagora
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
class Knowledge < ActiveRecord::Base
  belongs_to :ingenieur
  belongs_to :competence
  belongs_to :software

  validates_presence_of :ingenieur_id
  validate do |record|
    # length consistency
    if record.competence && record.software
      record.errors.add_to_base _('You have to specify a software or a domain.')
    end
    if !record.competence && !record.software
      record.errors.add_to_base _('You cannot specify a software and a domain.')
    end
  end
  # TODO : seach name of the levels ?
  # maybe a new Model ?
  validates_numericality_of :level, :integer => true,
    :greater_than => 0, :lesser_than => 6

  def name
    ( competence_id && competence_id != 0 ? competence.name : software.name )
  end

end
