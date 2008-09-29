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
class TypeissuesController < ApplicationController
  def index
    @typeissue_pages, @typeissues = paginate :typeissues, :per_page => 10
  end

  def show
    @typeissue = Typeissue.find(params[:id])
  end

  def new
    @typeissue = Typeissue.new
  end

  def create
    @typeissue = Typeissue.new(params[:typeissue])
    if @typeissue.save
      flash[:notice] = _("A new type of issue was successfully created.")
      redirect_to typeissues_path
    else
      render :action => 'new'
    end
  end

  def edit
    @typeissue = Typeissue.find(params[:id])
  end

  def update
    @typeissue = Typeissue.find(params[:id])
    if @typeissue.update_attributes(params[:typeissue])
      flash[:notice] = _("An issue type was successfully updated.")
      redirect_to typeissue_path(@typeissue)
    else
      render :action => 'edit'
    end
  end

  def destroy
    Typeissue.find(params[:id]).destroy
    redirect_to typeissues_path
  end
end
