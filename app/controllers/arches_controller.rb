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
class ArchesController < ApplicationController
  def index
    @arch_pages, @arches = paginate :arches, :per_page => 10
  end

  def show
    @arch = Arch.find(params[:id])
  end

  def create
    @arch = Arch.new(params[:arch])
    if @arch.save
      flash[:notice] = _('Arch was successfully created.')
      redirect_to arches_path
    else
      render :action => 'new'
    end
  end

  def new
    @arch = Arch.new
  end

  def edit
    @arch = Arch.find(params[:id])
  end

  def update
    @arch = Arch.find(params[:id])
    if @arch.update_attributes(params[:arch])
      flash[:notice] = _('Arch was successfully updated.')
      redirect_to arch_path(@arch)
    else
      render :action => 'edit'
    end
  end

  def destroy
    Arch.find(params[:id]).destroy
    redirect_to arches_url
  end
end
