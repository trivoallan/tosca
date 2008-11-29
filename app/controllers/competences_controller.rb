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
class CompetencesController < ApplicationController
  def index
    options = { :per_page => 50, :order => 'competences.name',
      :page => params[:page] }
    @competences = Competence.paginate options
  end

  def show
    @competence = Competence.find(params[:id])
  end

  def new
    @competence = Competence.new
  end

  def create
    @competence = Competence.new(params[:competence])
    if @competence.save
      flash[:notice] = _('Skill was successfully created.')
      redirect_to competences_path
    else
      render :action => 'new'
    end
  end

  def edit
    @competence = Competence.find(params[:id])
  end

  def update
    @competence = Competence.find(params[:id])
    if @competence.update_attributes(params[:competence])
      flash[:notice] = _('Skill was successfully updated.')
      redirect_to competence_path(@competence)
    else
      render :action => 'edit'
    end
  end

  def destroy
    Competence.find(params[:id]).destroy
    redirect_to competences_path
  end
end
