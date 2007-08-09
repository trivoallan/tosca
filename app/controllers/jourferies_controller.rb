#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class JourferiesController < ApplicationController
  helper :pages
  def index
    @jourferie_pages, @jourferies = paginate :jourferies, :per_page => 10
  end

  def show
    @jourferie = Jourferie.find(params[:id])
  end

  def new
    @jourferie = Jourferie.new
  end

  def create
    @jourferie = Jourferie.new(params[:jourferie])
    @jourferie.jour = @jourferie.jour.change(:hour => 0, :minute => 0, :second => 0)
    if @jourferie.save
      flash[:notice] = 'Jourferie was successfully created.'
      redirect_to jourferies_path
    else
      render :action => 'new'
    end
  end

  def edit
    @jourferie = Jourferie.find(params[:id])
  end

  def update
    @jourferie = Jourferie.find(params[:id])
    if @jourferie.update_attributes(params[:jourferie])
      flash[:notice] = 'Jourferie was successfully updated.'
      redirect_to jourferie_path(@jourferie)
    else
      render :action => 'edit'
    end
  end

  def destroy
    Jourferie.find(params[:id]).destroy
    redirect_to jourferies_path
  end
end
