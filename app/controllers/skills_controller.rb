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
class SkillsController < ApplicationController
  def index
    options = { :per_page => 50, :order => 'skills.name',
      :page => params[:page] }
    @skills = Skill.paginate options
  end

  def show
    @skill = Skill.find(params[:id])
  end

  def new
    @skill = Skill.new
  end

  def create
    @skill = Skill.new(params[:skill])
    if @skill.save
      flash[:notice] = _('Skill was successfully created.')
      redirect_to skills_path
    else
      render :action => 'new'
    end
  end

  def edit
    @skill = Skill.find(params[:id])
  end

  def update
    @skill = Skill.find(params[:id])
    if @skill.update_attributes(params[:skill])
      flash[:notice] = _('Skill was successfully updated.')
      redirect_to skill_path(@skill)
    else
      render :action => 'edit'
    end
  end

  def destroy
    Skill.find(params[:id]).destroy
    redirect_to skills_path
  end
end
