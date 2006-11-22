class SoclesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @socle_pages, @socles = paginate :socles, :per_page => 10
  end

  def show
    @socle = Socle.find(params[:id])
  end

  def new
    @socle = Socle.new
    @machines = Machine.find_all
  end

  def create
    @socle = Socle.new(params[:socle])
    if @socle.save
      flash[:notice] = 'Socle was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @socle = Socle.find(params[:id])
  end

  def update
    @socle = Socle.find(params[:id])
    if @socle.update_attributes(params[:socle])
      flash[:notice] = 'Socle was successfully updated.'
      redirect_to :action => 'show', :id => @socle
    else
      render :action => 'edit'
    end
  end

  def destroy
    Socle.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
