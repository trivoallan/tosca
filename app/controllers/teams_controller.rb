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
class TeamsController < ApplicationController
  auto_complete_for :contract, :name, :team, :contract
  auto_complete_for :user, :name, :team, :user,
                    :conditions => { :client_id => nil }
  def index
    @teams = Team.paginate :page => params[:page]
  end

  def show
    @team = Team.find(params[:id])
    @team.contracts.sort!{|c1, c2| c1.name <=> c2.name}
  end

  def new
    @team = Team.new
    _form
  end

  def edit
    @team = Team.find(params[:id])
    _form
  end

  def create
    @team = Team.new(params[:team])
    if @team.save
      flash[:notice] = _('Team %s was successfully created.') % @team.name
      redirect_to(@team)
    else
      _form and render :action => "new"
    end
  end

  def update
    @team = Team.find(params[:id])
    if @team.update_attributes(params[:team])
      flash[:notice] = _('Team %s was successfully updated.') % @team.name
      redirect_to(@team)
    else
      _form and render :action => "edit"
    end
  end

  def destroy
    @team = Team.find(params[:id])
    @team.destroy
    redirect_to(teams_url)
  end

private
  def _form
    @users = User.find_select(User::EXPERT_OPTIONS)
    @team.contracts.sort!{|c1, c2| c1.name <=> c2.name}
  end

end
