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
class Rules::ComponentsController < ApplicationController

  def index
    @components = Rules::Component.paginate :page => params[:page]
  end

  def show
    @component = Rules::Component.find(params[:id])
  end

  def new
    @component = Rules::Component.new
  end

  def edit
    @component = Rules::Component.find(params[:id])
  end

  def create
    @component = Rules::Component.new(params[:component])
    if @component.save
      flash[:notice] = _("'%s' was successfully created.") % @component.name
      redirect_to(@component)
    else
      render :action => "new"
    end
  end

  def update
    @component = Rules::Component.find(params[:id])
    if @component.update_attributes(params[:component])
      flash[:notice] = _("'%s' was successfully updated.") % @component.name
      redirect_to(@component)
    else
      render :action => "edit"
    end
  end

  def destroy
    @component = Rules::Component.find(params[:id])
    @component.destroy
    redirect_to(rules_components_path)
  end

end
