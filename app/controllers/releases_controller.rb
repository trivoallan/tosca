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
  end

  def new
    @release = Release.new
    @release.version_id = params[:version_id]
    _form
  end

  def create
    @release = Release.new(params[:release])
    @release.logiciel_id = Version.find(@release.version_id).logiciel_id
    if @release.save
      flash[:notice] = _('This release has been successfully created.')
      redirect_to version_path(@release.version)
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
      flash[:notice] = _('This release has been successfully updated.')
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
    if @release.version
      options = { :conditions => [ 'contributions.logiciel_id = ?', @release.version.logiciel_id ] }
    end
    @contributions = Contribution.find_select(options)
    @versions = Version.all.collect { |v| [ v.name, v.id ]}
    @contracts = Contract.find_select(Contract::OPTIONS)
  end
  
end
