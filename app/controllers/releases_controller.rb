class ReleasesController < ApplicationController
  helper :versions, :logiciels

  def index
    @release_pages, @releases = paginate :releases, :per_page => 10,
      :include => :version
  end

  def show
    options = { :include => [ { :contract => :client },
                              { :version => :logiciel } ] }
    @release = Release.find(params[:id], options)
    options = { :conditions => {:release_id => @release.id}, :order => 'chemin' }
  end

  def new
    @release = Release.new
    @release.paquet_id = params[:paquet_id]
    _form
  end

  def create
    @release = Release.new(params[:release])
    if @release.save
      flash[:notice] = _('Binary has beensuccessfully created.')
      redirect_to paquet_path(@release.paquet)
    else
      _form
      render :action => 'new'
    end
  end

  def edit
    @release = Release.find(params[:id])
    _form
  end

  def update
    @release = Release.find(params[:id])
    if @release.update_attributes(params[:release])
      flash[:notice] = _('Binary has been successfully updated.')
      redirect_to release_path(@release)
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    Release.find(params[:id]).destroy
    redirect_back
  end

  private
  def _form
    options = {}
    if @release.paquet
      options = { :conditions => [ 'contributions.logiciel_id = ?', @release.paquet.logiciel_id ] }
    end
    @contributions = Contribution.find_select(options)
    @paquets = Paquet.find_select(Paquet::OPTIONS)
    @arches = Arch.find_select
    @socles = Socle.find_select
  end
end
