class AppelsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  before_filter :verifie, :only => [ :show, :edit, :update, :destroy ]
  def verifie
    super(Appel)
  end


  def list
    @appel_pages, @appels = paginate :appels, :per_page => 10
  end

  def show
    @appel = Appel.find(params[:id])
  end

  def new
    @appel = Appel.new
    _form
  end

  def create
    @appel = Appel.new(params[:appel])
    if @appel.save
      flash[:notice] = 'l\'Appel a été créé.'
      redirect_to :action => 'list'
    else
      _form and render :action => 'new'
    end
  end

  def edit
    @appel = Appel.find(params[:id])
    _form
  end

  def update
    @appel = Appel.find(params[:id])
    if @appel.update_attributes(params[:appel])
      flash[:notice] = 'l\'appel a été mis à jour.'
      redirect_to :action => 'list'
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    Appel.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  private
  # conventions
  def _form   
    @ingenieurs = Ingenieur.find_select(Identifiant::SELECT_OPTIONS)
    @beneficiaires = Beneficiaire.find_select(Identifiant::SELECT_OPTIONS)
  end
end
