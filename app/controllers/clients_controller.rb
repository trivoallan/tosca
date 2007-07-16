#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class ClientsController < ApplicationController
  helper :demandes,:socles,:engagements, :contrats

  def index
    @client_pages, @clients = paginate :clients, :per_page => 10,
    :order => 'clients.nom', :include => [:image,:support]
  end

  def stats
    list
    @typedemandes = Typedemande.find(:all)
  end

  def show
    @client = Client.find(params[:id], :include => [:socles])
    # allows to see only binaries of this client for all without scope
    Binaire.set_scope(@client.contrat_ids) if @ingenieur
    render
    Binaire.remove_scope if @ingenieur
  end

  def new
    @client = Client.new
    _form
  end

  def create
    @client = Client.new(params[:client])
    if @client.save
      flash[:notice] = 'Client créé correctement.'
      redirect_to :action => 'index'
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
    redirect_to :action => 'index'
  end

  private
  def _form
    @images = Image.find(:all)
    @supports = Support.find_select
    @socles = Socle.find_select
  end

end
