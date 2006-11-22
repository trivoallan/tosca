class IngenieursController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @ingenieur_pages, @ingenieurs = paginate :ingenieurs, :per_page => 10
  end

  def show
    @ingenieur = Ingenieur.find(params[:id])
  end

  def new
    @ingenieur = Ingenieur.new
    @identifiants = Identifiant.find_all
    @competences = Competence.find_all
    @contrats = Contrat.find_all
  end

  def create
    @ingenieur = Ingenieur.new(params[:ingenieur])
    @competences = Competence.find_all
    @contrats = Contrat.find_all
    if @ingenieur.save
      flash[:notice] = 'Ingenieur was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @ingenieur = Ingenieur.find(params[:id])
    @identifiants = Identifiant.find_all
    @competences = Competence.find_all
    @contrats = Contrat.find_all
  end

  def update
    @ingenieur = Ingenieur.find(params[:id])
    @identifiants = Identifiant.find_all
    @competences = Competence.find_all
    @contrats = Contrat.find_all
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
      redirect_to :action => 'show', :id => @ingenieur
    else
      render :action => 'edit'
    end

  end

  def destroy
    Ingenieur.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
