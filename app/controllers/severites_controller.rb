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
class SeveritesController < ApplicationController

  def index
    @severite_pages, @severites = paginate :severites, :per_page => 10
  end

  def show
    @severite = Severite.find(params[:id])
  end

  def new
    @severite = Severite.new
  end

  def create
    @severite = Severite.new(params[:severite])
    if @severite.save
      flash[:notice] = _("Severity was successfully created.")
      redirect_to severites_path
    else
      render :action => 'new'
    end
  end

  def edit
    @severite = Severite.find(params[:id])
  end

  def update
    @severite = Severite.find(params[:id])
    if @severite.update_attributes(params[:severite])
      flash[:notice] = _("Severity was successfully updated.")
      redirect_to severite_path(@severite)
    else
      render :action => 'edit'
    end
  end

  def destroy
    Severite.find(params[:id]).destroy
    redirect_to severites_path
  end
end
