class DependancesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @dependance_pages, @dependances = paginate :dependances, :per_page => 10
  end

  def show
    @dependance = Dependance.find(params[:id])
  end

  def new
    @dependance = Dependance.new
  end

  def create
    @dependance = Dependance.new(params[:dependance])
    if @dependance.save
      flash[:notice] = 'Dependance was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @dependance = Dependance.find(params[:id])
  end

  def update
    @dependance = Dependance.find(params[:id])
    if @dependance.update_attributes(params[:dependance])
      flash[:notice] = 'Dependance was successfully updated.'
      redirect_to :action => 'show', :id => @dependance
    else
      render :action => 'edit'
    end
  end

  def destroy
    Dependance.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
