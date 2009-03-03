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
class SeveritiesController < ApplicationController

  def index
    @severities = Severity.paginate :page => params[:page]
  end

  def show
    @severity = Severity.find(params[:id])
  end

  def new
    @severity = Severity.new
  end

  def create
    @severity = Severity.new(params[:severity])
    if @severity.save
      flash[:notice] = _("Severity was successfully created.")
      redirect_to severities_path
    else
      render :action => 'new'
    end
  end

  def edit
    @severity = Severity.find(params[:id])
  end

  def update
    @severity = Severity.find(params[:id])
    if @severity.update_attributes(params[:severity])
      flash[:notice] = _("Severity was successfully updated.")
      redirect_to severity_path(@severity)
    else
      render :action => 'edit'
    end
  end

  def destroy
    Severity.find(params[:id]).destroy
    redirect_to severities_path
  end
end
