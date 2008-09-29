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
class UrlreversementsController < ApplicationController
  helper :softwares

  def index
    @urlreversement_pages, @urlreversements = paginate :urlreversements,
    :per_page => 10
  end

  def show
    @urlreversement = Urlreversement.find(params[:id])
  end

  def new
    @urlreversement = Urlreversement.new
    _form
  end

  def create
    @urlreversement = Urlreversement.new(params[:urlreversement])
    if @urlreversement.save
      flash[:notice] = _('Urlreversement was successfully created.')
      redirect_to contribution_path(@urlreversement.contribution_id)
    else
      _form and render :action => 'new'
    end
  end

  def edit
    @urlreversement = Urlreversement.find(params[:id])
    _form
  end

  def update
    @urlreversement = Urlreversement.find(params[:id])
    if @urlreversement.update_attributes(params[:urlreversement])
      flash[:notice] = _('Urlreversement was successfully updated.')
      redirect_to contribution_path(@urlreversement.contribution_id)
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    url = Urlreversement.find(params[:id])
    if session[:user].role_id != 1 and # admin_role
        url.contribution.ingenieur_id != @ingenieur.id
      flash[:warn] = _('You are not the author of this one.')
      redirect_to contribution_path(url.contribution) and return
    end
    url.destroy
    redirect_to contributions_path
  end

private
  def _form
    @contributions = Contribution.find(:all)
    if params[:contribution_id]
      @urlreversement.contribution_id = params[:contribution_id].to_i
    end
  end
end
