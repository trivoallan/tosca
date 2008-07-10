class ReleasesController < ApplicationController
  helper :versions, :logiciels

  def index
    @release_pages, @releases = paginate :releases, :per_page => 10,
      :include => :version
  end

  def show
    options = { :include => [{:paquet => [:conteneur,
                                          { :contract => :client },
                                          { :logiciel => :groupe}]},
                            :socle,:arch] }
    @binaire = Binaire.find(params[:id], options)
    options = { :conditions => {:binaire_id => @binaire.id}, :order => 'chemin' }
  end

  def new
    @binaire = Binaire.new
    @binaire.paquet_id = params[:paquet_id]
    _form
  end

  def create
    @binaire = Binaire.new(params[:binaire])
    if @binaire.save
      flash[:notice] = _('Binary has beensuccessfully created.')
      redirect_to paquet_path(@binaire.paquet)
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
    redirect_back
  end

  private
  def _form
    options = {}
    if @binaire.paquet
      options = { :conditions => [ 'contributions.logiciel_id = ?', @binaire.paquet.logiciel_id ] }
    end
    @contributions = Contribution.find_select(options)
    @paquets = Paquet.find_select(Paquet::OPTIONS)
    @arches = Arch.find_select
    @socles = Socle.find_select
  end
end
