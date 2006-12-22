#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class SoclesController < ApplicationController
  helper :clients,:paquets,:machines

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @socle_pages, @socles = paginate :socles, :per_page => 10,
    :include => [:machine, :client]
  end

  def show
    @socle = Socle.find(params[:id])
    @paquets = Paquet.find_all_by_socle_id(@socle.id)
  end

  def new
    @socle = Socle.new
    _form
  end

  def create
    @socle = Socle.new(params[:socle])
    if @socle.save
      flash[:notice] = 'Socle was successfully created.'
      redirect_to :action => 'list'
    else
      _form
      render :action => 'new'
    end
  end

  def edit
    @socle = Socle.find(params[:id])
    _form
  end

  def update
    @socle = Socle.find(params[:id])
    if @socle.update_attributes(params[:socle])
      flash[:notice] = 'Socle was successfully updated.'
      redirect_to :action => 'show', :id => @socle
    else
      _form
      render :action => 'edit'
    end
  end

  def destroy
    Socle.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  private 
  def _form
    @machines = Machine.find_all
    @clients = Client.find(:all, :select => 'clients.nom, clients.id')
  end
end
