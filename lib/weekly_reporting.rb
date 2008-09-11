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
module WeeklyReporting

  # Give the status of requests flow during a certain time,
  # specified from @date[:first_day] to @date[:end_day]
  def compute_weekly_report(recipient_ids)
    values = {
      :first_day => @date[:first_day],
      :last_day=> @date[:end_day],
      :recipient_ids => recipient_ids
    }
    scope = { :find => { :conditions =>
        [ 'requests.recipient_id IN (:recipient_ids) AND requests.updated_on BETWEEN :first_day AND :last_day', values ] }
    }
    Request.send(:with_scope, scope) {
      first_day = values[:first_day].to_formatted_s(:db)
      last_day = values[:last_day].to_formatted_s(:db)

      options = { :conditions =>
        [ 'requests.created_on BETWEEN :first_day AND :last_day', values ],
        :order => 'clients.name, requests.id', :include => [{:recipient => :client},
                                                           :statut,:typerequest] }
      @requests_created = Request.find(:all, options)

      options[:conditions] = [ 'requests.statut_id = ?', 7 ] # 7 => Closed.
      @requests_closed = Request.find(:all, options)

      options[:conditions] = [ 'requests.statut_id = ?', 8 ] # 8 => Cancelled.
      @requests_cancelled = Request.find(:all, options)
    }
  end
end
