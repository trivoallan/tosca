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
class ChangelogsController < ApplicationController
  def index
    render :nothing => true
  end

  def show
    @changelog = Changelog.find(params[:id])
  end

  def new
    @changelog = Changelog.new
  end

  def create
    @changelog = Changelog.new(params[:changelog])
    if @changelog.save
      flash[:notice] = 'Changelog was successfully created.'
      redirect_to changelogs_path
    else
      render :action => 'new'
    end
  end

  def edit
    @changelog = Changelog.find(params[:id])
  end

  def update
    @changelog = Changelog.find(params[:id])
    if @changelog.update_attributes(params[:changelog])
      flash[:notice] = 'Changelog was successfully updated.'
      redirect_to changelog_path(@changelog)
    else
      render :action => 'edit'
    end
  end

  def destroy
    Changelog.find(params[:id]).destroy
    redirect_to changelogs_path
  end
end
