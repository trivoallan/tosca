#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class PiecejointesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  def list
    @piecejointe_pages, @piecejointes = paginate :piecejointes, :per_page => 10,
    :include => [:commentaire]
  end

  def show
    @piecejointe = Piecejointe.find(params[:id])
  end

  def new
    @piecejointe = Piecejointe.new
  end

  def create
    @piecejointe = Piecejointe.new(params[:piecejointe])
    if @piecejointe.save
      flash[:notice] = 'Piecejointe was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @piecejointe = Piecejointe.find(params[:id])
  end

  def update
    @piecejointe = Piecejointe.find(params[:id])
    if @piecejointe.update_attributes(params[:piecejointe])
      flash[:notice] = 'Piecejointe was successfully updated.'
      redirect_to :action => 'show', :id => @piecejointe
    else
      render :action => 'edit'
    end
  end

  def destroy
    Piecejointe.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
