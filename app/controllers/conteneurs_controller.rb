class ConteneursController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @conteneur_pages, @conteneurs = paginate :conteneurs, :per_page => 10
  end

  def show
    @conteneur = Conteneur.find(params[:id])
  end

  def new
    @conteneur = Conteneur.new
  end

  def create
    @conteneur = Conteneur.new(params[:conteneur])
    if @conteneur.save
      flash[:notice] = 'Conteneur was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @conteneur = Conteneur.find(params[:id])
  end

  def update
    @conteneur = Conteneur.find(params[:id])
    if @conteneur.update_attributes(params[:conteneur])
      flash[:notice] = 'Conteneur was successfully updated.'
      redirect_to :action => 'show', :id => @conteneur
    else
      render :action => 'edit'
    end
  end

  def destroy
    Conteneur.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
