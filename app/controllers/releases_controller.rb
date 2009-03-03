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
require 'contribution'

class ReleasesController < ApplicationController
  helper :versions, :softwares, :archives

  def index
    @releases = Release.paginate :include => :version, :page => params[:page]
  end

  def show
    options = { :include => [ :contract , :version ] }
    @release = Release.find(params[:id], options)
  end

  def new
    @release = Release.new
    @release.version_id = params[:version_id]
    _form
  end

  def create
    @release = Release.new(params[:release])
    if @release.version.generic?
      flash[:warn] = _("This release can not be created, because it is associated
        with a generic version.<br/>Please create a specific version below.")
      redirect_to new_version_path(:version_id => @release.version_id)
    else
      if @release.save
        flash[:notice] = _('This release has been successfully created.')
        redirect_to(@release.version ? version_path(@release.version) : @release)
      else
        _form
        render :action => 'new'
      end
    end
  end

  def edit
    @release = Release.find(params[:id])
    _form
  end

  def update
    @release = Release.find(params[:id])
    if @release.update_attributes(params[:release])
      flash[:notice] = _('This release has been successfully updated.')
      redirect_to release_path(@release)
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    Release.find(params[:id]).destroy
    redirect_back
  end

  private
  def _form
    options = {}
    if @release.version
      options = { :conditions => [ 'contributions.software_id = ?', @release.version.software_id ] }
    end
    @contributions = Contribution.find_select(options)
    @versions = Version.all.collect { |v| [ v.full_name, v.id ]}
    @contracts = Contract.find_select(Contract::OPTIONS)
  end

end
