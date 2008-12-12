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
    options = { :per_page => 25, :include => [:client],
      :order => 'documents.date_delivery DESC', :page => params[:page] }

    if params.has_key? :filters
      session[:documents_filters] = Filters::Documents.new(params[:filters])
    end

    conditions = nil
    documents_filters = session[:documents_filters]
    if documents_filters
      # Specification of a filter f :
      #   [ field, database field, operation ]
      # All the fields must be coherent with lib/filters.rb related Struct.
      conditions = Filters.build_conditions(documents_filters, [
        [:name, 'documents.name', :like],
        [:documenttype_id, 'documents.documenttype_id', :equal],
        [:filename, 'documents.file', :like]
      ])
      @filters = documents_filters
    end
    flash[:conditions] = options[:conditions] = conditions

    @documents = Document.paginate options

    # panel on the left side.
    if request.xhr?
      render :layout => false
    else
      _panel
      @partial_for_summary = 'documents_info'
    end
  end

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
      redirect_to documents_path
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
    redirect_to documents_path(:id => documenttype_id)
  end

  private
  def _form
    @clients = Client.find_select
    @documenttypes = Documenttype.find_select
    @users = User.find_select
  end

  def _panel
    @documenttypes = Documenttype.find_select
    if params.has_key?(:filters) and params[:filters].has_key?(:documenttype)
      @documenttype = Documentype.find(params[:filters][:documenttype_id])
    end
  end

end
