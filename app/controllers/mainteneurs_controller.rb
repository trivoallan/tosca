#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class MainteneursController < ApplicationController
  def index
    @mainteneur_pages, @mainteneurs = paginate :mainteneurs, :per_page => 10, :order => 'nom'
  end

  def show
    @mainteneur = Mainteneur.find(params[:id])
  end

  def new
    @mainteneur = Mainteneur.new
  end

  def create
    @mainteneur = Mainteneur.new(params[:mainteneur])
    if @mainteneur.save
      flash[:notice] = 'Mainteneur was successfully created.'
      redirect_to mainteneurs_path
    else
      render :action => 'new'
    end
  end

  def edit
    @mainteneur = Mainteneur.find(params[:id])
  end

  def update
    @mainteneur = Mainteneur.find(params[:id])
    if @mainteneur.update_attributes(params[:mainteneur])
      flash[:notice] = 'Mainteneur was successfully updated.'
      redirect_to mainteneur_path(@mainteneur)
    else
      render :action => 'edit'
    end
  end

  def destroy
    Mainteneur.find(params[:id]).destroy
    redirect_to mainteneurs_path
  end
end
