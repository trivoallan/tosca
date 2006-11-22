class BouquetsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @bouquet_pages, @bouquets = paginate :bouquets, :per_page => 10
  end

  def show
    @bouquet = Bouquet.find(params[:id])
  end

  def new
    @bouquet = Bouquet.new
  end

  def create
    @bouquet = Bouquet.new(params[:bouquet])
    if @bouquet.save
      flash[:notice] = 'Bouquet was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @bouquet = Bouquet.find(params[:id])
  end

  def update
    @bouquet = Bouquet.find(params[:id])
    if @bouquet.update_attributes(params[:bouquet])
      flash[:notice] = 'Bouquet was successfully updated.'
      redirect_to :action => 'show', :id => @bouquet
    else
      render :action => 'edit'
    end
  end

  def destroy
    Bouquet.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
