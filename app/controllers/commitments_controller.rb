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
class CommitmentsController < ApplicationController
  def index
    @commitment_pages, @commitments = paginate :commitments,
    :per_page => 20, :order => "typeissue_id, severite_id",
    :include => [:typeissue,:severite]
  end

  def show
    @commitment = Commitment.find(params[:id])
  end

  def new
    @commitment = Commitment.new
    _form
  end

  def create
    @commitment = Commitment.new(params[:commitment])
    if @commitment.save
      flash[:notice] = 'Commitment was successfully created.'
      redirect_to commitments_path
    else
      _form
      render :action => 'new'
    end
  end

  def edit
    @commitment = Commitment.find(params[:id])
    _form
  end

  def update
    @commitment = Commitment.find(params[:id])
    if @commitment.update_attributes(params[:commitment])
      flash[:notice] = 'Commitment was successfully updated.'
      redirect_to commitments_path
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    Commitment.find(params[:id]).destroy
    redirect_to commitments_path
  end

  private
  def _form
    @typeissues = Typeissue.find_select
    @severites = Severite.find_select
  end
end
