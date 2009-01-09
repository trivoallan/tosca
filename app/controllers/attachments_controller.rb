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
class AttachmentsController < ApplicationController
  def index
    options = {:page => params[:page], :per_page => 10, :include => [:comment]}
    @attachments = Attachment.paginate options
  end

  def show
    @attachment = Attachment.find(params[:id])
  end

  def new
    @attachment = Attachment.new
  end

  def create
    @attachment = Attachment.new(params[:attachment])
    if @attachment.save
      flash[:notice] = 'Attachment was successfully created.'
      redirect_to attachment_path(@attachment)
    else
      render :action => 'new'
    end
  end

  def edit
    @attachment = Attachment.find(params[:id])
  end

  def update
    @attachment = Attachment.find(params[:id])
    if @attachment.update_attributes(params[:attachment])
      flash[:notice] = 'Attachment was successfully updated.'
      redirect_to attachment_path(@attachment)
    else
      render :action => 'edit'
    end
  end

  def destroy
    Attachment.find(params[:id]).destroy
    redirect_to attachments_path
  end

end
