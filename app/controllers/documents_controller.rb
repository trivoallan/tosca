#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
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
      @typedocument = Typedocument.find(params[:id])
      conditions = ["documents.typedocument_id = ?", @typedocument.id]
    else
      conditions = nil
    end
    @document_pages, @documents = paginate :documents, :per_page => 10,
      :order => "documents.date_delivery DESC", :conditions => conditions,
      :include => [:user]

    # Disabled, beacause the search boxes in the panel don't work.
    # It may be repaired in a future version.
    #
    # panel on the left side
#    if request.xhr?
#      render :partial => 'documents_list', :layout => false
#    else
#      _panel
#      @partial_for_summary = 'documents_info'
#    end
  end

  def select
    @typedocuments = Typedocument.find(:all)
    if @beneficiaire
      @typedocuments.delete_if { |t|
        Document.count(:conditions => "documents.typedocument_id = #{t.id}") == 0
      }
    end

    # TODO : fusionner avec la répétition dans l'index
    # panel on the left side
#    if request.xhr?
#      render :partial => 'documents_list', :layout => false
#    else
#      _panel
#      @partial_for_summary = 'documents_info'
#    end

  end

  def show
    @document = Document.find(params[:id])
  end

  def new
    @document = Document.new
    # we can have the type predefined if we are already on a category
    @document.typedocument_id = params[:id]
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
    typedocument_id = doc.typedocument_id
    doc.destroy
    redirect_to list_document_path(:id => typedocument_id)
  end

  private
  def _form
    @clients = Client.find_select
    @typedocuments = Typedocument.find :all
    @users = User.find_select
  end

  def _panel
    @count = {}
    @typedocuments = Typedocument.find_select
    @count[:documents] = Document.count
  end

end
