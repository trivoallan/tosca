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

  def list
    @competences = Competence.find_all
    @ingenieur_pages, @ingenieurs = paginate :ingenieurs, :per_page => 10,
    :include => [:identifiant]
  end

  def show
    @ingenieur = Ingenieur.find(params[:id])
  end

  def new
    @ingenieur = Ingenieur.new
    _form
  end

  def create
    @ingenieur = Ingenieur.new(params[:ingenieur])
    _form
    if @ingenieur.save
      flash[:notice] = 'Ingenieur was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @ingenieur = Ingenieur.find(params[:id])
    _form
  end

  def update
    @ingenieur = Ingenieur.find(params[:id])
    _form
    # TODO c'est moche, il faut faire mieux !
    if @params[:competence_ids]
      @ingenieur.competences = Competence.find(@params[:competence_ids]) 
    else
      @ingenieur.competences = []
      @ingenieur.errors.add_on_empty('competences') 
    end

    if @params[:contrat_ids]
      @ingenieur.contrats = Contrat.find(@params[:contrat_ids]) 
    else
      @ingenieur.contrats = []
      @ingenieur.errors.add_on_empty('contrats') 
    end

    if @params[:contrat_ids] and @params[:competence_ids] and 
        @ingenieur.update_attributes(params[:ingenieur]) 
      flash[:notice] = 'Ingenieur was successfully updated.'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end

  end

  def destroy
    inge = Ingenieur.find(params[:id])
    identifiant = Identifiant.find(inge.identifiant_id)
    inge.destroy
    identifiant.destroy
    redirect_to :action => 'list'
  end

  private
  def _form
    @identifiants = Identifiant.find_all
    @competences = Competence.find_all
    @contrats = Contrat.find_all
  end
end
