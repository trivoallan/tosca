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
class ContributiontypesController < ApplicationController
  def index
    @contributiontypes = Contributiontype.all
  end

  def show
    @contributiontype = Contributiontype.find(params[:id])
  end

  def new
    @contributiontype = Contributiontype.new
  end

  def create
    @contributiontype = Contributiontype.new(params[:contributiontype])
    if @contributiontype.save
      flash[:notice] = _("A new type of contribution was successfully created.")
      redirect_to contributiontypes_path
    else
      render :action => 'new'
    end
  end

  def edit
    @contributiontype = Contributiontype.find(params[:id])
  end

  def update
    @contributiontype = Contributiontype.find(params[:id])
    if @contributiontype.update_attributes(params[:contributiontype])
      flash[:notice] = _("A Type of contribution was successfully updated.")
      redirect_to contributiontype_path(@contributiontype)
    else
      render :action => 'edit'
    end
  end

  def destroy
    Contributiontype.find(params[:id]).destroy
    redirect_to contributiontypes_path
  end
end
