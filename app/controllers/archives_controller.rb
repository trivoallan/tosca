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
class ArchivesController < ApplicationController
  helper :releases, :archives

  def index
    render :nothing => true
  end

  def show
    @archive = Archive.find(params[:id])
  end

  def new
    @archive = Archive.new
    @archive.release_id = params[:release_id]
    _form
  end

  def create
    @archive = Archive.new(params[:archive])
    if @archive.save
      flash[:notice] = _('This archive has been successfully created.')
      redirect_to release_path(@archive.release)
    else
      _form
      render :action => 'new'
    end
  end

  def edit
    @archive = Archive.find(params[:id])
    _form
  end

  def update
    @archive = Archive.find(params[:id])
    if @archive.update_attributes(params[:archive])
      flash[:notice] = _('This archive has been successfully updated.')
      redirect_to archive_path(@archive)
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    Archive.find(params[:id]).destroy
    redirect_back
  end

  private
  def _form
    @releases = Release.all.collect { |r| [r.full_software_name, r.id ]}
  end

end
