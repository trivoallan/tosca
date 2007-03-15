#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class SeveritesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @severite_pages, @severites = paginate :severites, :per_page => 10
  end

  def show
    @severite = Severite.find(params[:id])
  end

  def new
    @severite = Severite.new
  end

  def create
    @severite = Severite.new(params[:severite])
    if @severite.save
      flash[:notice] = 'Severite was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @severite = Severite.find(params[:id])
  end

  def update
    @severite = Severite.find(params[:id])
    if @severite.update_attributes(params[:severite])
      flash[:notice] = 'Severite was successfully updated.'
      redirect_to :action => 'show', :id => @severite
    else
      render :action => 'edit'
    end
  end

  def destroy
    Severite.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
