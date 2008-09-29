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
class GroupesController < ApplicationController
  # public access to the list
  before_filter :login_required, :except => [:index,:show]

  helper :softwares

  def index
    @groupe_pages, @groupes = paginate :groupes, :per_page => 20,
    :order => 'groupes.name'
  end

  def show
    @groupe = Groupe.find(params[:id])
  end

  def new
    @groupe = Groupe.new
  end

  def create
    @groupe = Groupe.new(params[:groupe])
    if @groupe.save
      flash[:notice] = _('Group was successfully created.')
      redirect_to groupes_path
    else
      render :action => 'new'
    end
  end

  def edit
    @groupe = Groupe.find(params[:id])
  end

  def update
    @groupe = Groupe.find(params[:id])
    if @groupe.update_attributes(params[:groupe])
      flash[:notice] = _('Group was successfully updated.')
      redirect_to groupe_path(@groupe)
    else
      render :action => 'edit'
    end
  end

  def destroy
    Groupe.find(params[:id]).destroy
    redirect_to groupes_path
  end
end
