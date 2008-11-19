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
class VersionsController < ApplicationController
  helper :filters, :softwares, :releases

  def index
    options = { :per_page => 15 }

    # Specification of a filter f :
    # [ namespace, field, database field, operation ]
    params_version = params['version']
    conditions = Filters.build_conditions(params_version, [
       ['version', 'versions.name', :like ]
     ]) unless params_version.blank?
    flash[:conditions] = options[:conditions] = conditions

    @version_pages, @versions = paginate :versions, options

    # panel on the left side
    if request.xhr?
      render :partial => 'versions_list', :layout => false
    else
      _panel
      @partial_for_summary = 'versions_info'
    end
  end

  def show
    @version = Version.find(params[:id])
  end

  def new
    if params[:version_id]
      #We come from the creation of a new release from a version which is generic
      @version = Version.find(params[:version_id])
      @version.generic = false
    else
      @version = Version.new
    end
    _form
    @version.software_id = params[:software_id] if params[:software_id]
  end

  def create
    @version = Version.new(params[:version])
    if @version.save
      flash[:notice] = _('The version %s has been created.') % @version.name
      redirect_to software_path(@version.software)
    else
      _form
      render :action => 'new'
    end
  end

  def edit
    @version = Version.find(params[:id])
    _form
  end

  def update
    @version = Version.find(params[:id])
    if @version.update_attributes(params[:version])
      flash[:notice] = _('The version %s has been updated.') % @version.full_name
      redirect_to version_path(@version)
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    Version.find(params[:id]).destroy
    redirect_back
  end

  private
  def _form
    @softwares = Software.find_select
    @groupes = Groupe.find_select
    @socles = Socle.find_select
    @contracts = Contract.find_select(Contract::OPTIONS)
  end

  def _panel
    @count = {}
    @clients = Client.find_select(:conditions => 'clients.inactive = 0')
    @count[:versions] = Version.count
  end

end
