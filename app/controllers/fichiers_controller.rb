class FichiersController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @fichier_pages, @fichiers = paginate :fichiers, :per_page => 10
  end

  def show
    @fichier = Fichier.find(params[:id])
  end

  def new
    @fichier = Fichier.new
  end

  def create
    @fichier = Fichier.new(params[:fichier])
    if @fichier.save
      flash[:notice] = 'Fichier was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @fichier = Fichier.find(params[:id])
  end

  def update
    @fichier = Fichier.find(params[:id])
    if @fichier.update_attributes(params[:fichier])
      flash[:notice] = 'Fichier was successfully updated.'
      redirect_to :action => 'show', :id => @fichier
    else
      render :action => 'edit'
    end
  end

  def destroy
    Fichier.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
