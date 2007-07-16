#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class FichiersController < ApplicationController
  def index
    @fichier_pages, @fichiers = paginate :fichiers, :per_page => 10
  end

  def show
    @fichier = Fichier.find(params[:id])
  end

  def new
    @fichier = Fichier.new
  end

  def create
    @fichier = Fichier.new(params[:fichier])
    if @fichier.save
      flash[:notice] = 'Fichier was successfully created.'
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def edit
    @fichier = Fichier.find(params[:id])
  end

  def update
    @fichier = Fichier.find(params[:id])
    if @fichier.update_attributes(params[:fichier])
      flash[:notice] = 'Fichier was successfully updated.'
      redirect_to :action => 'show', :id => @fichier
    else
      render :action => 'edit'
    end
  end

  def destroy
    Fichier.find(params[:id]).destroy
    redirect_to :action => 'index'
  end
end
