#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class SoclesController < ApplicationController
  helper :clients,:binaires,:machines,:paquets

  before_filter :verifie, :only => 
    [ :show, :edit, :update, :destroy ]

  def verifie
    super(Socle)
  end


  before_filter :verifie, :only => [ :show, :edit, :update, :destroy ]

  def verifie
    super(Socle)
  end

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @socle_pages, @socles = paginate :socles, :per_page => 250,
    :include => [:machine]
  end

  def show
    @socle = Socle.find(params[:id], :include => [:machine])
    @binaires = Binaire.find_all_by_socle_id(@socle.id, 
                                             :order => 'binaires.nom,paquets.version',
                                             :include => [:paquet])
  end

  def new
    @socle = Socle.new
    _form
  end

  def create
    @socle = Socle.new(params[:socle])
    if @socle.save
      @socle.clients = Client.find(@params[:client_ids]) if @params[:client_ids]
      @socle.save
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
    @socle.clients = Client.find(@params[:client_ids]) if @params[:client_ids]
    if @socle.update_attributes(params[:socle])
      flash[:notice] = 'Socle was successfully updated.'
      redirect_to :action => 'list'
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
