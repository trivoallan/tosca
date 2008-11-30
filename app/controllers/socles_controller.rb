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
class SoclesController < ApplicationController
  helper :clients, :machines, :versions

  def index
    options = { :page => params[:page], :include => [:machine],
      :order=> 'socles.name' }
    @socles = Socle.paginate options
  end

  def show
    @socle = Socle.find(params[:id], :include => [:machine])
  end

  def new
    @socle = Socle.new
    _form
  end

  def create
    @socle = Socle.new(params[:socle])
    if @socle.save
      @socle.save
      flash[:notice] = _('A System was successfully created.')
      redirect_to socles_path
    else
      _form
      render :action => 'new'
    end
  end

  def edit
    @socle = Socle.find(params[:id])
    _form
  end

  def update
    @socle = Socle.find(params[:id])
    if @socle.update_attributes(params[:socle])
      flash[:notice] = _('A System was successfully updated.')
      redirect_to socles_path
    else
      _form
      render :action => 'edit'
    end
  end

  def destroy
    Socle.find(params[:id]).destroy
    redirect_to socles_path
  end

  private
  def _form
    @machines = Machine.find :all
    @clients = Client.find_select
  end

end
