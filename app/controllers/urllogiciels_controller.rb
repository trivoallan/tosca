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
class UrllogicielsController < ApplicationController
  helper :logiciels

  def index
    @urllogiciel_pages, @urllogiciels = paginate :urllogiciels,
     :per_page => 10, :include => [:logiciel,:typeurl],
     :order => 'urllogiciels.logiciel_id'
  end

  def show
    @urllogiciel = Urllogiciel.find(params[:id])
  end

  def new
    @urllogiciel = Urllogiciel.new
    @urllogiciel.logiciel_id = params[:logiciel_id]
    _form
  end

  def create
    @urllogiciel = Urllogiciel.new(params[:urllogiciel])
    if @urllogiciel.save
      flash[:notice] = _('The url of "%s" has been created successfully.') %
        @urllogiciel.valeur
      redirect_to logiciel_path(@urllogiciel.logiciel)
    else
      _form and render :action => 'new'
    end
  end

  def edit
    @urllogiciel = Urllogiciel.find(params[:id])
    _form
  end

  def update
    @urllogiciel = Urllogiciel.find(params[:id])
    if @urllogiciel.update_attributes(params[:urllogiciel])
      flash[:notice] = _("The Url has bean updated successfully.")
      redirect_to logiciel_path(@urllogiciel.logiciel)
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    url = Urllogiciel.find(params[:id])
    return_url = logiciel_path(url.logiciel)
    url.destroy
    redirect_to return_url
  end

private
  def _form
    @typeurls = Typeurl.find_select
    @logiciels = Logiciel.find_select
  end
end
