class TempsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @temps_pages, @temps = paginate :temps, :per_page => 10
  end

  def show
    @temps = Temps.find(params[:id])
  end

  def new
    @temps = Temps.new
  end

  def create
    @temps = Temps.new(params[:temps])
    if @temps.save
      flash[:notice] = 'Temps was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @temps = Temps.find(params[:id])
  end

  def update
    @temps = Temps.find(params[:id])
    if @temps.update_attributes(params[:temps])
      flash[:notice] = 'Temps was successfully updated.'
      redirect_to :action => 'show', :id => @temps
    else
      render :action => 'edit'
    end
  end

  def destroy
    Temps.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
