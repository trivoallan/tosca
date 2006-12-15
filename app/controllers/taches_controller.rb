class TachesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @tache_pages, @taches = paginate :taches, :per_page => 10
  end

  def show
    @tache = Tache.find(params[:id])
  end

  def new
    @tache = Tache.new
  end

  def create
    @tache = Tache.new(params[:tache])
    if @tache.save
      flash[:notice] = 'Tache was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @tache = Tache.find(params[:id])
  end

  def update
    @tache = Tache.find(params[:id])
    if @tache.update_attributes(params[:tache])
      flash[:notice] = 'Tache was successfully updated.'
      redirect_to :action => 'show', :id => @tache
    else
      render :action => 'edit'
    end
  end

  def destroy
    Tache.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
