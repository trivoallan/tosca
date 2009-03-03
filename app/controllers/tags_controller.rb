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
class TagsController < ApplicationController
  def index
    @tags = Tag.paginate :order => 'tags.name', :page => params[:page]
  end

  def show
    @tag = Tag.find(params[:id])
  end

  def new
    @tag = Tag.new
    _form
  end

  def create
    @tag = Tag.new(params[:tag])
    @tag.user_id = @session_user.id
    if @tag.save
      flash[:notice] = _('Skill was successfully created.')
      redirect_to tags_path
    else
      render :action => 'new'
    end
  end

  def edit
    @tag = Tag.find(params[:id])
    _form
  end

  def update
    @tag = Tag.find(params[:id])
    if @tag.update_attributes(params[:tag])
      flash[:notice] = _('Skill was successfully updated.')
      redirect_to tag_path(@tag)
    else
      render :action => 'edit'
    end
  end

  def destroy
    Tag.find(params[:id]).destroy
    redirect_to tags_path
  end

private
  def _form
    @skills = Skill.find_select
    @contracts = Contract.find_select(Contract::OPTIONS)
  end
end
