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
class DocumenttypesController < ApplicationController
  def index
    @documenttypes = Documenttype.all
  end

  def show
    @documenttype = Documenttype.find(params[:id])
  end

  def new
    @documenttype = Documenttype.new
  end

  def create
    @documenttype = Documenttype.new(params[:documenttype])
    if @documenttype.save
      flash[:notice] = 'Documenttype was successfully created.'
      redirect_to documenttypes_path
    else
      render :action => 'new'
    end
  end

  def edit
    @documenttype = Documenttype.find(params[:id])
  end

  def update
    @documenttype = Documenttype.find(params[:id])
    if @documenttype.update_attributes(params[:documenttype])
      flash[:notice] = 'Documenttype was successfully updated.'
      redirect_to documenttype_path(@documenttype)
    else
      render :action => 'edit'
    end
  end

  def destroy
    Documenttype.find(params[:id]).destroy
    redirect_to documenttypes_path
  end

end
