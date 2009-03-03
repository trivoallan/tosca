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
class StatutsController < ApplicationController
  def index
    @statuts = Statut.all(:order => 'id')
  end

  def help
    @statut = Statut.find(params[:id])
    render :action => 'show', :layout => false
  end

  def show
    @statut = Statut.find(params[:id])
  end

  def new
    @statut = Statut.new
  end

  def create
    @statut = Statut.new(params[:statut])
    if @statut.save
      flash[:notice] = _('Status was successfully created.')
      redirect_to statuts_path
    else
      render :action => 'new'
    end
  end

  def edit
    @statut = Statut.find(params[:id])
  end

  def update
    @statut = Statut.find(params[:id])
    if @statut.update_attributes(params[:statut])
      flash[:notice] = _('Statut was successfully updated.')
      redirect_to statut_path(@statut)
    else
      render :action => 'edit'
    end
  end

  def destroy
    Statut.find(params[:id]).destroy
    redirect_to statuts_path
  end
end
