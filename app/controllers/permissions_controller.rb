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
class PermissionsController < ApplicationController
  def index
    options = { :order => 'permissions.name', :include => [:roles],
      :page => params[:page] }
    @permissions = Permission.paginate options
  end

  def show
    @permission = Permission.find(params[:id])
  end

  def new
    @permission = Permission.new
    _form
  end

  def create
    @permission = Permission.new(params[:permission])
    if @permission.save
      flash[:notice] = _('Permission was successfully created.')
      redirect_to permissions_path
    else
      _form and render :action => 'new'
    end
  end

  def edit
    @permission = Permission.find(params[:id])
    _form
  end

  def update
    @permission = Permission.find(params[:id])
    if @permission.update_attributes(params[:permission])
      flash[:notice] = _('Permission was successfully updated.')
      redirect_to permissions_path
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    Permission.find(params[:id]).destroy
    redirect_to permissions_path
  end

  private
  def _form
    @roles = Role.find_select
  end
end
