class ProjetsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @projet_pages, @projets = paginate :projets, :per_page => 10
  end

  def show
    @projet = Projet.find(params[:id])
  end

  def new
    @projet = Projet.new
  end

  def create
    @projet = Projet.new(params[:projet])
    if @projet.save
      flash[:notice] = 'Projet was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @projet = Projet.find(params[:id])
  end

  def update
    @projet = Projet.find(params[:id])
    if @projet.update_attributes(params[:projet])
      flash[:notice] = 'Projet was successfully updated.'
      redirect_to :action => 'show', :id => @projet
    else
      render :action => 'edit'
    end
  end

  def destroy
    Projet.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
