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
class TypeurlsController < ApplicationController
  def index
    @typeurl_pages, @typeurls = paginate :typeurls, :per_page => 50
  end

  def show
    @typeurl = Typeurl.find(params[:id])
  end

  def new
    @typeurl = Typeurl.new
  end

  def create
    @typeurl = Typeurl.new(params[:typeurl])
    if @typeurl.save
      flash[:notice] = _("A url type was successfully created.")
      redirect_to typeurls_path
    else
      render :action => 'new'
    end
  end

  def edit
    @typeurl = Typeurl.find(params[:id])
  end

  def update
    @typeurl = Typeurl.find(params[:id])
    if @typeurl.update_attributes(params[:typeurl])
      flash[:notice] = _("A url type was successfully updated.")
      redirect_to typeurl_path(@typeurl)
    else
      render :action => 'edit'
    end
  end

  def destroy
    Typeurl.find(params[:id]).destroy
    redirect_to typeurls_path
  end
end
