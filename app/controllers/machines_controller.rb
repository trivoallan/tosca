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
class MachinesController < ApplicationController
  helper :socles

  def index
    options = { :include => [:socle,:hote], :order =>
        'machines.hote_id, machines.acces' }
    @machines = Machine.all(options)
  end

  def show
    @machine = Machine.find(params[:id])
  end

  def new
    @machine = Machine.new
    _form
  end

  def create
    @machine = Machine.new(params[:machine])
    if @machine.save
      flash[:notice] = _('Machine was successfully created.')
      redirect_to machines_path
    else
      _form
      render :action => 'new'
    end
  end

  def edit
    @machine = Machine.find(params[:id])
    _form
  end

  def update
    @machine = Machine.find(params[:id])
    if @machine.update_attributes(params[:machine])
      flash[:notice] = _('Machine was successfully updated.')
      redirect_to machine_path(@machine)
    else
      _form
      render :action => 'edit'
    end
  end

  def destroy
    Machine.find(params[:id]).destroy
    redirect_to machines_path
  end

  private
  def _form
    @socles = Socle.find(:all, :select => 'socles.name, socles.id',
                         :order => 'socles.name')
    conditions = ['machines.virtuelle = ?', 0]
    @hotes = Machine.find(:all, :select => 'machines.acces, machines.id',
                          :conditions => conditions)
  end
end
