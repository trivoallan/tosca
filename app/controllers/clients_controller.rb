#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class ClientsController < ApplicationController
  helper :demandes,:socles,:engagements

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @client_pages, @clients = paginate :clients, :per_page => 10, 
    :order => 'clients.nom', :include => [:photo,:support]
  end

  def show
    @client = Client.find(params[:id], :include => [:socles])
  end

  def new
    @client = Client.new
    _form
  end

  def create
    @client = Client.new(params[:client])
    if @client.save
      flash[:notice] = 'Client créé correctement.'
      redirect_to :action => 'list'
    else
      _form and render :action => 'new'
    end
  end

  def edit
    @client = Client.find(params[:id])
    _form
  end

  def update
    @client = Client.find(params[:id])
    if @client.update_attributes(params[:client])
      flash[:notice] = 'Client mis à jour.'
      redirect_to :action => 'show', :id => @client
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    Client.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  private
  def _form
    @photos = Photo.find(:all)
    @supports = Support.find_select
    @socles = Socle.find_select
  end

end
