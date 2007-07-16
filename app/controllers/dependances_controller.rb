#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class DependancesController < ApplicationController
  def index
    @dependance_pages, @dependances = paginate :dependances, :per_page => 10
    render :action => 'list'
  end

  def show
    @dependance = Dependance.find(params[:id])
  end

  def new
    @dependance = Dependance.new
  end

  def create
    @dependance = Dependance.new(params[:dependance])
    if @dependance.save
      flash[:notice] = 'Dependance was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @dependance = Dependance.find(params[:id])
  end

  def update
    @dependance = Dependance.find(params[:id])
    if @dependance.update_attributes(params[:dependance])
      flash[:notice] = 'Dependance was successfully updated.'
      redirect_to :action => 'show', :id => @dependance
    else
      render :action => 'edit'
    end
  end

  def destroy
    Dependance.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
