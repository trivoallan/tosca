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
class TyperequestsController < ApplicationController
  def index
    @typerequest_pages, @typerequests = paginate :typerequests, :per_page => 10
  end

  def show
    @typerequest = Typerequest.find(params[:id])
  end

  def new
    @typerequest = Typerequest.new
  end

  def create
    @typerequest = Typerequest.new(params[:typerequest])
    if @typerequest.save
      flash[:notice] = _("A new type of request was successfully created.")
      redirect_to typerequests_path
    else
      render :action => 'new'
    end
  end

  def edit
    @typerequest = Typerequest.find(params[:id])
  end

  def update
    @typerequest = Typerequest.find(params[:id])
    if @typerequest.update_attributes(params[:typerequest])
      flash[:notice] = _("A request type was successfully updated.")
      redirect_to typerequest_path(@typerequest)
    else
      render :action => 'edit'
    end
  end

  def destroy
    Typerequest.find(params[:id]).destroy
    redirect_to typerequests_path
  end
end
