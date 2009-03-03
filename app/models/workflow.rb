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
class Workflow < ActiveRecord::Base
  belongs_to :issuetype
  belongs_to :statut

  serialize :allowed_status_ids, Array

  validates_presence_of :statut, :issuetype

  def allowed_status
    Statut.find(self.allowed_status_ids)
  end

  def name
    "<b>#{self.statut.name}</b> => (#{self.allowed_status.join(', ')})"
  end

  include Comparable
  # Used for workflows.sort! call, among other things
  def <=>(other)
    self.statut_id <=> other.statut_id
  end
end
