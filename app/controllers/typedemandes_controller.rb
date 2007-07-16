#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class TypedemandesController < ApplicationController
  def index
    @typedemande_pages, @typedemandes = paginate :typedemandes, :per_page => 10
    render :action => 'list'
  end

  def show
    @typedemande = Typedemande.find(params[:id])
  end

  def new
    @typedemande = Typedemande.new
  end

  def create
    @typedemande = Typedemande.new(params[:typedemande])
    if @typedemande.save
      flash[:notice] = 'Typedemande was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @typedemande = Typedemande.find(params[:id])
  end

  def update
    @typedemande = Typedemande.find(params[:id])
    if @typedemande.update_attributes(params[:typedemande])
      flash[:notice] = 'Typedemande was successfully updated.'
      redirect_to :action => 'show', :id => @typedemande
    else
      render :action => 'edit'
    end
  end

  def destroy
    Typedemande.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
