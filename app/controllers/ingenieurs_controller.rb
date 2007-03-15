#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class IngenieursController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }
  before_filter :verifie, :only => [ :show, :edit, :update, :destroy ]

  def list
    @competences = Competence.find(:all)
    @ingenieur_pages, @ingenieurs = paginate :ingenieurs, :per_page => 20,
    :include => [:identifiant,:competences]
  end

  def show
    @ingenieur = Ingenieur.find(params[:id], 
                                :include => [:identifiant,:competences])
  end

  def new
    @ingenieur = Ingenieur.new
    _form
  end

  def create
    @ingenieur = Ingenieur.new(params[:ingenieur])
    if @ingenieur.save
      flash[:notice] = 'Ingenieur was successfully created.'
      redirect_to :action => 'list'
    else
      _form and render :action => 'new'
    end
  end

  def edit
    @ingenieur = Ingenieur.find(params[:id])
    _form
  end

  def update
    @ingenieur = Ingenieur.find(params[:id])
    if @ingenieur.update_attributes(params[:ingenieur]) 
      flash[:notice] = 'Ingenieur was successfully updated.'
      redirect_to :action => 'list'
    else
      _form and render :action => 'edit'
    end

  end

  # TODO : mettre dans le modèle, avec un before_destroy
  def destroy
    inge = Ingenieur.find(params[:id])
    identifiant = Identifiant.find(inge.identifiant_id)
    inge.destroy
    identifiant.destroy
    redirect_to :action => 'list'
  end

  private
  def _form
    @identifiants = Identifiant.find_select
    @competences = Competence.find_select
    @contrats = Contrat.find_select(Contrat::OPTIONS)
  end

  def verifie
    super(Ingenieur)
  end
end
