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
class RolesController < ApplicationController
  def index
    options = { :order => 'permissions.name', :include => :roles }
    @permissions = Permission.all(options)
    @roles = Role.all
  end

  def show
    @role = Role.find(params[:id])
  end

  def new
    @role = Role.new
    _form
  end

  def create
    @role = Role.new(params[:role])
    if @role.save
      flash[:notice] = _("The role %s was succefully created.") % "\"#{@role.name}\""
      redirect_to roles_url
    else
      render :action => 'new'
    end
  end

  def edit
    @role = Role.find(params[:id])
    _form
  end

  def update
    @role = Role.find(params[:id])
    if @role.update_attributes(params[:role])
      flash[:notice] = _("The role %s was succefully updated.") % "\"#{@role.name}\""
      redirect_to roles_url
    else
      render :action => 'edit'
    end
  end

  def destroy
    Role.find(params[:id]).destroy
    redirect_to roles_url
  end

  private
  def _form
    @permissions = Permission.find_select
  end
end
