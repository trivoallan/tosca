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
class AlertsController < ApplicationController
  helper :issues

  def index
    @teams = Team.find_select
  end

  def on_submit
    flash[:team_ids] = params[:team][:ids]
    new_issue
  end

  def ajax_on_submit
    flash[:team_ids] = flash[:team_ids]
    new_issue
    render :partial => 'ajax_on_submit'
  end

  private
  def new_issue
    team = Team.find(flash[:team_ids])
    conditions = [ 'issues.contract_id IN (?) AND issues.statut_id = 1', team.contract_ids ]
    @issues_found = Issue.find(:all, :conditions => conditions)
  end

end
