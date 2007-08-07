#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class BinairesController < ApplicationController
  helper :paquets, :logiciels

  def index
    @binaire_pages, @binaires = paginate :binaires, :per_page => 10,
      :include => [:socle, :arch, :paquet]
  end

  def show
    @binaire = Binaire.find(params[:id], :include => [:paquet,:socle,:arch])
    options = { :conditions => {:binaire_id => @binaire.id} }
    @fichierbinaires = Fichierbinaire.find(:all, options)
  end

  def new
    @binaire = Binaire.new
    _form
  end

  def create
    @binaire = Binaire.new(params[:binaire])
    if @binaire.save
      flash[:notice] = _('Binary has beensuccessfully created.')
      redirect_to binaires_path
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
      flash[:notice] = _('Binary has been successfully updated.')
      redirect_to binaire_path(@binaire)
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    Binaire.find(params[:id]).destroy
    redirect_to binaires_path
  end

  private
  def _form
    @contributions = Contribution.find(:all)
    @paquets = Paquet.find(:all, Paquet::OPTIONS)
    @arches = Arch.find_select
    @socles = Socle.find_select
  end
end
