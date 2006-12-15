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
    _form
    if @projet.save
      flash[:notice] = 'Projet was successfully created.'
      _post(params)
      @projet.save
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @projet = Projet.find(params[:id])
    _form
  end

  def update
    @projet = Projet.find(params[:id])
    _form
    _post(params)
    if @projet.update_attributes(params[:projet])
      flash[:notice] = 'Projet was successfully updated.'
      redirect_to :action => 'show', :id => @projet
    else
      render :action => 'edit'
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
    @logiciels = Logiciel.find_all
    # TODO c'est moche, il faut faire mieux !
  end

  def _post(params)
    #TODO : c'est moche et c'est pas DRY
    return unless params
    if params[:beneficiaire_ids]
      @projet.beneficiaires = Beneficiaire.find(params[:beneficiaire_ids]) 
    else
      @projet.beneficiaires = []
      @projet.errors.add_on_empty('beneficiaires') 
    end

    if @params[:ingenieur_ids]
      @projet.ingenieurs = Ingenieur.find(@params[:ingenieur_ids]) 
    else
      @projet.ingenieurs = []
      @projet.errors.add_on_empty('ingenieurs') 
    end

    if @params[:logiciel_ids]
      @projet.logiciels = Logiciel.find(@params[:logiciel_ids]) 
    else
      @projet.logiciels = []
      @projet.errors.add_on_empty('logiciels') 
    end

  end
end
