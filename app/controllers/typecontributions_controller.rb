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
class TypecontributionsController < ApplicationController
  def index
    @typecontribution_pages, @typecontributions = paginate :typecontributions, :per_page => 10
  end

  def show
    @typecontribution = Typecontribution.find(params[:id])
  end

  def new
    @typecontribution = Typecontribution.new
  end

  def create
    @typecontribution = Typecontribution.new(params[:typecontribution])
    if @typecontribution.save
      flash[:notice] = _("A new type of contribution was successfully created.")
      redirect_to typecontributions_path
    else
      render :action => 'new'
    end
  end

  def edit
    @typecontribution = Typecontribution.find(params[:id])
  end

  def update
    @typecontribution = Typecontribution.find(params[:id])
    if @typecontribution.update_attributes(params[:typecontribution])
      flash[:notice] = _("A Type of contribution was successfully updated.")
      redirect_to typecontribution_path(@typecontribution)
    else
      render :action => 'edit'
    end
  end

  def destroy
    Typecontribution.find(params[:id]).destroy
    redirect_to typecontributions_path
  end
end
