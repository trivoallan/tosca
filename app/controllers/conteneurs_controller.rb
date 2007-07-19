#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class ConteneursController < ApplicationController
  def index
    @conteneur_pages, @conteneurs = paginate :conteneurs, :per_page => 10
  end

  def show
    @conteneur = Conteneur.find(params[:id])
  end

  def new
    @conteneur = Conteneur.new
  end

  def create
    @conteneur = Conteneur.new(params[:conteneur])
    if @conteneur.save
      flash[:notice] = 'Conteneur was successfully created.'
      redirect_to conteneurs_path
    else
      render :action => 'new'
    end
  end

  def edit
    @conteneur = Conteneur.find(params[:id])
  end

  def update
    @conteneur = Conteneur.find(params[:id])
    if @conteneur.update_attributes(params[:conteneur])
      flash[:notice] = 'Conteneur was successfully updated.'
      redirect_to conteneur_path(@conteneur)
    else
      render :action => 'edit'
    end
  end

  def destroy
    Conteneur.find(params[:id]).destroy
    redirect_to conteneurs_path
  end
end
