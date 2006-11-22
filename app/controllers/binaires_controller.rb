class BinairesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @binaire_pages, @binaires = paginate :binaires, :per_page => 10
  end

  def show
    @binaire = Binaire.find(params[:id])
  end

  def new
    @binaire = Binaire.new
    _form
  end

  def create
    @binaire = Binaire.new(params[:binaire])
    if @binaire.save
      flash[:notice] = 'Binaire was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @binaire = Binaire.find(params[:id])
    _form
  end

  def update
    @binaire = Binaire.find(params[:id])
    if @binaire.update_attributes(params[:binaire])
      flash[:notice] = 'Binaire was successfully updated.'
      redirect_to :action => 'show', :id => @binaire
    else
      render :action => 'edit'
    end
  end

  def destroy
    Binaire.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  private
  def _form
    @correctifs = Correctif.find_all
  end
end
