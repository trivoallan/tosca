#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class ClientsController < ApplicationController
  helper :demandes, :socles, :engagements, :contrats

  def index
    active = 'clients.inactive = 0'
    options = { :per_page => 10, :order => 'clients.name',
      :include => [:image], :conditions => active }
    @client_pages, @clients = paginate :clients, options
  end

  def stats
    index
    @typedemandes = Typedemande.find(:all)
  end

  def show
    @client = Client.find(params[:id], :include => [:socles])
    # allows to see only binaries of this client for all without scope
    begin
      Binaire.set_scope(@client.contrat_ids) if @ingenieur
      render
    ensure
      Binaire.remove_scope if @ingenieur
    end
  end

  def new
    @client = Client.new
    _form
  end

  def create
    @client = Client.new(params[:client])
    if @client.save
      flash[:notice] = _('Client created successfully.') + '<br />' +
        _('You have now to create the associated contract.')
      redirect_to new_contrat_path(:id => @client.id)
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
      flash[:notice] = _('Client updated successfully.')
      redirect_to client_path(@client)
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    Client.find(params[:id]).destroy
    redirect_to clients_path
  end

  private
  def _form
    # only client picture.
    @images = Image.find(:all, :include => [:client], :conditions =>
      'images.logiciel_id IS NULL')
    # It's the only way to add new system to its own scope
    Socle.send(:with_exclusive_scope) do
      @socles = Socle.find(:all, :order => 'name')
    end
  end

end
