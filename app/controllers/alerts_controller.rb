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
  helper :requests

  def index
    @teams = Team.find_select
  end

  def on_submit
    flash[:team_ids] = params[:team][:ids]
    new_request
  end

  def ajax_on_submit
    flash[:team_ids] = flash[:team_ids]
    new_request
    render :partial => 'ajax_on_submit'
  end

  private
  def new_request
    team = Team.find(flash[:team_ids])
    conditions = [ 'requests.contract_id IN (?) AND requests.statut_id = 1', team.contract_ids ]
    @requests_found = Request.find(:all, :conditions => conditions)
  end

end
