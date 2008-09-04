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
class TypedocumentsController < ApplicationController
  def index
    @typedocument_pages, @typedocuments = paginate :typedocuments, :per_page => 10
  end

  def show
    @typedocument = Typedocument.find(params[:id])
  end

  def new
    @typedocument = Typedocument.new
  end

  def create
    @typedocument = Typedocument.new(params[:typedocument])
    if @typedocument.save
      flash[:notice] = 'Typedocument was successfully created.'
      redirect_to typedocuments_path
    else
      render :action => 'new'
    end
  end

  def edit
    @typedocument = Typedocument.find(params[:id])
  end

  def update
    @typedocument = Typedocument.find(params[:id])
    if @typedocument.update_attributes(params[:typedocument])
      flash[:notice] = 'Typedocument was successfully updated.'
      redirect_to typedocument_path(@typedocument)
    else
      render :action => 'edit'
    end
  end

  def destroy
    Typedocument.find(params[:id]).destroy
    redirect_to typedocuments_path
  end

end
