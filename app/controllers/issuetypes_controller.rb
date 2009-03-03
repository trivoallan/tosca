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
class IssuetypesController < ApplicationController
  helper :workflows

  def index
    @issuetypes = Issuetype.all
  end

  def show
    @issuetype = Issuetype.find(params[:id])
    @issuetype.workflows.sort!
  end

  def new
    @issuetype = Issuetype.new
  end

  def create
    @issuetype = Issuetype.new(params[:issuetype])
    if @issuetype.save
      flash[:notice] = _("A new type of issue was successfully created.")
      redirect_to issuetypes_path
    else
      render :action => 'new'
    end
  end

  def edit
    @issuetype = Issuetype.find(params[:id])
  end

  def update
    @issuetype = Issuetype.find(params[:id])
    if @issuetype.update_attributes(params[:issuetype])
      flash[:notice] = _("An issue type was successfully updated.")
      redirect_to issuetype_path(@issuetype)
    else
      render :action => 'edit'
    end
  end

  def destroy
    Issuetype.find(params[:id]).destroy
    redirect_to issuetypes_path
  end
end
