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
class UrlsoftwaresController < ApplicationController
  helper :softwares

  def index
    @urlsoftware_pages, @urlsoftwares = paginate :urlsoftwares,
     :per_page => 10, :include => [:software,:typeurl],
     :order => 'urlsoftwares.software_id'
  end

  def show
    @urlsoftware = Urlsoftware.find(params[:id])
  end

  def new
    @urlsoftware = Urlsoftware.new
    @urlsoftware.software_id = params[:software_id]
    _form
  end

  def create
    @urlsoftware = Urlsoftware.new(params[:urlsoftware])
    if @urlsoftware.save
      flash[:notice] = _('The url of "%s" has been created successfully.') %
        @urlsoftware.valeur
      redirect_to software_path(@urlsoftware.software)
    else
      _form and render :action => 'new'
    end
  end

  def edit
    @urlsoftware = Urlsoftware.find(params[:id])
    _form
  end

  def update
    @urlsoftware = Urlsoftware.find(params[:id])
    if @urlsoftware.update_attributes(params[:urlsoftware])
      flash[:notice] = _("The Url has bean updated successfully.")
      redirect_to software_path(@urlsoftware.software)
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    url = Urlsoftware.find(params[:id])
    return_url = software_path(url.software)
    url.destroy
    redirect_to return_url
  end

private
  def _form
    @typeurls = Typeurl.find_select
    @softwares = Software.find_select
  end
end
