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
class Issuetype < ActiveRecord::Base
  has_many :commitments
  has_many :issues
  has_many :workflows


  # Only ids, it's use is restricted to expert view
  def allowed_statuses_ids(from_status_id)
    w = self.workflows.first(:conditions => {:statut_id => from_status_id})
    if w
      res = w.allowed_status_ids
    else # default case : nearly all statuses
      [2,3,4,5,6,7,8].delete_if{|s| s == from_status_id}
    end
  end

  # Status objects, can be used for every views
  def allowed_statuses(from_status_id, user)
    @@active_statuses ||= Statut.all(:conditions => ["statuts.active = ?", true]).collect(&:id)
    statuses_ids = allowed_statuses_ids(from_status_id)
    statuses_ids -= @@active_statuses if user.recipient?
    return statuses_ids if statuses_ids.empty?
    Statut.find_select(:conditions => ['statuts.id IN (?)', statuses_ids ],
                       :order => 'statuts.id')
  end

  def fake4translation
    N_("Information")
    N_("Incident")
    N_("Evolution")
    N_("Call-out")
    N_("Analysis")
    N_("Delivery")
    N_("Documentation")
  end

end
