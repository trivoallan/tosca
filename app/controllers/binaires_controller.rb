#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class BinairesController < ApplicationController
  helper :paquets

  def index
    @binaire_pages, @binaires = paginate :binaires, :per_page => 10,
    :include => [:socle, :arch, :paquet]
    render :action => 'list'
  end

  def show
    @binaire = Binaire.find(params[:id], :include => [:paquet,:socle,:arch])
    @fichierbinaires = Fichierbinaire.find_all_by_binaire_id(@binaire.id)
  end

  def new
    @binaire = Binaire.new
    _form
  end

  def create
    @binaire = Binaire.new(params[:binaire])
    if @binaire.save
      flash[:notice] = 'Binaire was successfully created.'
      redirect_to :action => 'list'
    else
      _form
      render :action => 'new'
    end
  end

  def edit
    @binaire = Binaire.find(params[:id])
    _form
  end

  def update
    @binaire = Binaire.find(params[:id])
    if @binaire.update_attributes(params[:binaire])
      flash[:notice] = 'Binaire was successfully updated.'
      redirect_to :action => 'show', :id => @binaire
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    Binaire.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  private
  def _form
    @contributions = Contribution.find_all
    @paquets = Paquet.find(:all, Paquet::OPTIONS)
    @arches = Arch.find_all
    @socles = Socle.find_all
  end
end
