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
class LicensesController < ApplicationController
  def index
    @licenses = License.paginate :page => params[:page]
  end

  def show
    @license = License.find(params[:id])
  end

  def new
    @license = License.new
  end

  def create
    @license = License.new(params[:license])
    if @license.save
      flash[:notice] = 'License was successfully created.'
      redirect_to licenses_path
    else
      render :action => 'new'
    end
  end

  def edit
    @license = License.find(params[:id])
  end

  def update
    @license = License.find(params[:id])
    if @license.update_attributes(params[:license])
      flash[:notice] = 'License was successfully updated.'
      redirect_to license_path(@license)
    else
      render :action => 'edit'
    end
  end

  def destroy
    License.find(params[:id]).destroy
    redirect_to licenses_path
  end
end
