#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class StatutsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @statut_pages, @statuts = paginate :statuts, :per_page => 10
  end

  def help
    @statut = Statut.find(params[:id])
    render :action => 'show', :layout => false
  end

  def show
    @statut = Statut.find(params[:id])
  end

  def new
    @statut = Statut.new
  end

  def create
    @statut = Statut.new(params[:statut])
    if @statut.save
      flash[:notice] = 'Statut was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @statut = Statut.find(params[:id])
  end

  def update
    @statut = Statut.find(params[:id])
    if @statut.update_attributes(params[:statut])
      flash[:notice] = 'Statut was successfully updated.'
      redirect_to :action => 'show', :id => @statut
    else
      render :action => 'edit'
    end
  end

  def destroy
    Statut.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
