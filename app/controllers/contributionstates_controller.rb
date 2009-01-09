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
class ContributionstatesController < ApplicationController
  def index
    options = { :per_page => 10, :page => params[:page] }
    @contributionstates = Contributionstate.paginate options
  end

  def show
    @contributionstate = Contributionstate.find(params[:id])
  end

  def new
    @contributionstate = Contributionstate.new
  end

  def create
    @contributionstate = Contributionstate.new(params[:contributionstate])
    if @contributionstate.save
      flash[:notice] = 'Contributionstate was successfully created.'
      redirect_to contributionstates_path
    else
      render :action => 'new'
    end
  end

  def edit
    @contributionstate = Contributionstate.find(params[:id])
  end

  def update
    @contributionstate = Contributionstate.find(params[:id])
    if @contributionstate.update_attributes(params[:contributionstate])
      flash[:notice] = 'Contributionstate was successfully updated.'
      redirect_to contributionstate_path(@contributionstate)
    else
      render :action => 'edit'
    end
  end

  def destroy
    Contributionstate.find(params[:id]).destroy
    redirect_to contributionstates_path
  end
end
