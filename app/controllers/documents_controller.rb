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
class DocumentsController < ApplicationController
  helper :filters

  def index
    select
    render :action => "select"
  end

  def list
    flash[:notice]= flash[:notice]
    redirect_to select_documents_path and return unless params[:id]
    unless params[:id] == 'all'
      @documenttype = Documenttype.find(params[:id])
      conditions = ["documents.documenttype_id = ?", @documenttype.id]
    else
      conditions = nil
    end
    options = { :per_page => 25, :page => params[:page], :order =>
      'documents.date_delivery DESC', :conditions => conditions,
      :include => [:user] }
    @documents = Document.paginate options

    if request.xhr?
      render :layout => false
    else
      _panel
      @partial_for_summary = 'documents_info'
    end
  end

  def select
    @documenttypes = Documenttype.find(:all)
    @documenttypes.delete_if do |t|
      Document.count(:conditions => "documents.documenttype_id = #{t.id}") == 0
    end
  end

    # TODO : fusionner avec la répétition dans l'index
    # panel on the left side
#    if request.xhr?
#      render :partial => 'documents_list', :layout => false
#    else
#      _panel
#      @partial_for_summary = 'documents_info'
#    end

  def show
    @document = Document.find(params[:id])
  end

  def new
    @document = Document.new(:documenttype_id => params[:id])
    _form
  end

  def create
    @document = Document.new(params[:document])
    @document.user = session[:user]
    _form
    if @document.save
      flash[:notice] = _('Your document was successfully created')
      redirect_to select_documents_path
    else
      render :action => 'new'
    end
  end

  def edit
    @document = Document.find(params[:id])
    _form
  end

  def update
    @document = Document.find(params[:id])
    if @document.update_attributes(params[:document])
      flash[:notice] = _('your document was successfully updated')
      redirect_to document_path(@document)
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    doc = Document.find(params[:id])
    documenttype_id = doc.documenttype_id
    doc.destroy
    redirect_to list_document_path(:id => documenttype_id)
  end

  private
  def _form
    @clients = Client.find_select
    @documenttypes = Documenttype.find_select
    @users = User.find_select
  end

  def _panel
    @documenttypes = Documenttype.find_select
  end

end
