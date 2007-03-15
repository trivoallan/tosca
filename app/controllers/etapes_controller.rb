#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class EtapesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }
  before_filter :verifie, :only => [ :show, :edit, :update, :destroy ]


  def list
    @etape_pages, @etapes = paginate :etapes, :per_page => 10
  end

  def show
    @etape = Etape.find(params[:id])
  end

  def new
    @etape = Etape.new
  end

  def create
    @etape = Etape.new(params[:etape])
    if @etape.save
      flash[:notice] = 'Etape was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @etape = Etape.find(params[:id])
  end

  def update
    @etape = Etape.find(params[:id])
    if @etape.update_attributes(params[:etape])
      flash[:notice] = 'Etape was successfully updated.'
      redirect_to :action => 'show', :id => @etape
    else
      render :action => 'edit'
    end
  end

  def destroy
    Etape.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  private
  def verifie
    super(Etape)
  end
end
