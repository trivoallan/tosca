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
    @teams = Team.all
  end
  
  def update
    params[:alert].each do |param|
      #Check if the params are well formed
      if param.first =~ /hash_\d+/ and not param.last.empty?
        #We create or find this alert
        alert = Alert.find_or_create_by_team_id(param.first.gsub(/\d+/).first)
        alert.update_attribute(:hash_value, param.last)
      end
    end
    redirect_to :action => "index"
  end

  def show
    new_issue
  end

  def ajax_on_submit
    new_issue
    render :partial => 'ajax_on_submit'
  end

  private
  def new_issue
    #We remove the scope for the public user
    Issue.send(:with_exclusive_scope) do 
      alert = Alert.find(:first, :conditions => { :hash_value => params[:hash] })
      @issues_found = []
      if alert
        team = alert.team
        conditions = [ 'issues.contract_id IN (?) AND issues.statut_id = 1', team.contract_ids ]
        @issues_found = Issue.find(:all, :conditions => conditions)
      end
    end
  end

end
