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
class MainteneursController < ApplicationController
  def index
    @mainteneur_pages, @mainteneurs = paginate :mainteneurs, :per_page => 10, :order => 'name'
  end

  def show
    @mainteneur = Mainteneur.find(params[:id])
  end

  def new
    @mainteneur = Mainteneur.new
  end

  def create
    @mainteneur = Mainteneur.new(params[:mainteneur])
    if @mainteneur.save
      flash[:notice] = 'Mainteneur was successfully created.'
      redirect_to mainteneurs_path
    else
      render :action => 'new'
    end
  end

  def edit
    @mainteneur = Mainteneur.find(params[:id])
  end

  def update
    @mainteneur = Mainteneur.find(params[:id])
    if @mainteneur.update_attributes(params[:mainteneur])
      flash[:notice] = 'Mainteneur was successfully updated.'
      redirect_to mainteneur_path(@mainteneur)
    else
      render :action => 'edit'
    end
  end

  def destroy
    Mainteneur.find(params[:id]).destroy
    redirect_to mainteneurs_path
  end
end
