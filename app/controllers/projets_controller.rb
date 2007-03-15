#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class ProjetsController < ApplicationController
  auto_complete_for :logiciel, :nom

  helper :taches

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @projet_pages, @projets = paginate :projets, :per_page => 10
  end

  def show
    @projet = Projet.find(params[:id])
  end

  def new
    @projet = Projet.new
    _form
  end

  def create
    @projet = Projet.new(params[:projet])
    if @projet.save
      flash[:notice] = 'Projet was successfully created.'
      redirect_to :action => 'list'
    else
      _form and render :action => 'new'
    end
  end

  def edit
    @projet = Projet.find(params[:id])
    _form
  end

  def update
    @projet = Projet.find(params[:id])
    if @projet.update_attributes(params[:projet])
      flash[:notice] = 'Projet was successfully updated.'
      redirect_to :action => 'show', :id => @projet
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    Projet.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  private
  def _form
    @beneficiaires = Beneficiaire.find(:all, :include => [:identifiant])
    @ingenieurs = Ingenieur.find_presta(:all)
    @logiciels = Logiciel.find(:all)
  end

end
