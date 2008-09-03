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
class EtatreversementsController < ApplicationController
  def index
    @etatreversement_pages, @etatreversements =
      paginate :etatreversements, :per_page => 10
  end

  def show
    @etatreversement = Etatreversement.find(params[:id])
  end

  def new
    @etatreversement = Etatreversement.new
  end

  def create
    @etatreversement = Etatreversement.new(params[:etatreversement])
    if @etatreversement.save
      flash[:notice] = 'Etatreversement was successfully created.'
      redirect_to etatreversements_path
    else
      render :action => 'new'
    end
  end

  def edit
    @etatreversement = Etatreversement.find(params[:id])
  end

  def update
    @etatreversement = Etatreversement.find(params[:id])
    if @etatreversement.update_attributes(params[:etatreversement])
      flash[:notice] = 'Etatreversement was successfully updated.'
      redirect_to etatreversement_path(@etatreversement)
    else
      render :action => 'edit'
    end
  end

  def destroy
    Etatreversement.find(params[:id]).destroy
    redirect_to etatreversements_path
  end
end
