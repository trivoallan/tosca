#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class DistributeursController < ApplicationController
  def index
    @distributeur_pages, @distributeurs = paginate :distributeurs, :per_page => 10
    render :action => 'list'
  end

  def show
    @distributeur = Distributeur.find(params[:id])
  end

  def new
    @distributeur = Distributeur.new
  end

  def create
    @distributeur = Distributeur.new(params[:distributeur])
    if @distributeur.save
      flash[:notice] = 'Distributeur was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @distributeur = Distributeur.find(params[:id])
  end

  def update
    @distributeur = Distributeur.find(params[:id])
    if @distributeur.update_attributes(params[:distributeur])
      flash[:notice] = 'Distributeur was successfully updated.'
      redirect_to :action => 'show', :id => @distributeur
    else
      render :action => 'edit'
    end
  end

  def destroy
    Distributeur.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
