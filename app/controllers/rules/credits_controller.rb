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
class Rules::CreditsController < ApplicationController

  def index
    @credits = Rules::Credit.paginate :page => params[:page]
  end

  def show
    @credit = Rules::Credit.find(params[:id])
  end

  def new
    @credit = Rules::Credit.new
  end

  def edit
    @credit = Rules::Credit.find(params[:id])
  end

  def create
    @credit = Rules::Credit.new(params[:credit])
    if @credit.save
      flash[:notice] = _("'%s' was successfully created.") % @credit.name
      redirect_to(@credit)
    else
      render :action => "new"
    end
  end

  def update
    @credit = Rules::Credit.find(params[:id])
    if @credit.update_attributes(params[:credit])
      flash[:notice] = _("'%s' was successfully updated.") % @credit.name
      redirect_to(@credit)
    else
      render :action => "edit"
    end
  end

  def destroy
    @credit = Rules::Credit.find(params[:id])
    @credit.destroy
    redirect_to(rules_credits_path)
  end

end
