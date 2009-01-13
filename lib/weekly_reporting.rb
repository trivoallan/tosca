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
module WeeklyReporting

  # Give the status of issues flow during a certain time,
  # specified from @date[:first_day] to @date[:end_day]
  def compute_weekly_report(recipient_ids)
    values = {
      :first_day => @date[:first_day],
      :last_day=> @date[:end_day],
      :recipient_ids => recipient_ids
    }
    scope = { :find => { :conditions =>
          [ 'issues.recipient_id IN (:recipient_ids) AND issues.updated_on BETWEEN :first_day AND :last_day', values ] }
    }
    Issue.send(:with_scope, scope) {
      first_day = values[:first_day].to_formatted_s(:db)
      last_day = values[:last_day].to_formatted_s(:db)

      options = { :conditions =>
          [ 'issues.created_on BETWEEN :first_day AND :last_day', values ],
        :order => 'clients.name, issues.id', :include => [{:recipient => :client},
          :statut,:issuetype] }
      @issues_created = Issue.all(options)

      options[:conditions] = [ 'issues.statut_id = ?', 7 ] # 7 => Closed.
      @issues_closed = Issue.all(options)

      options[:conditions] = [ 'issues.statut_id = ?', 8 ] # 8 => Cancelled.
      @issues_cancelled = Issue.all(options)
    }
  end

end
