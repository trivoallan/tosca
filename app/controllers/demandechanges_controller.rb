class DemandechangesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @demandechanges_pages, @demandechanges = paginate :demandechanges, 
    :per_page => 10, :order => "created_on"

  end

  def show
    @demandechange = Demandechange.find(params[:id])
  end

  def new
    @demandechange = Demandechange.new
  end

  def create
    @demandechange = Demandechange.new(params[:demandechange])
    if @demandechange.save
      flash[:notice] = 'Demandechange was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @demandechange = Demandechange.find(params[:id])
    @statuts = Statut.find_all
  end

  def update
    @demandechange = Demandechange.find(params[:id])
    if @demandechange.update_attributes(params[:demandechange])
      flash[:notice] = 'Demandechange was successfully updated.'
      redirect_to :action => 'show', :id => @demandechange
    else
      render :action => 'edit'
    end
  end

  def destroy
    Demandechange.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
