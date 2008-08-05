class VersionsController < ApplicationController
  helper :filters, :logiciels, :releases

  def index
    options = { :per_page => 15 }

    # Specification of a filter f :
    # [ namespace, field, database field, operation ]
    params_version = params['version']
    conditions = Filters.build_conditions(params_version, [
       ['version', 'versions.name', :like ]
     ]) unless params_version.blank?
    flash[:conditions] = options[:conditions] = conditions

    @version_pages, @versions = paginate :versions, options

    # panel on the left side
    if request.xhr?
      render :partial => 'versions_list', :layout => false
    else
      _panel
      @partial_for_summary = 'versions_info'
    end
  end

  def show
    @version = Version.find(params[:id])
  end

  def new
    if params[:version_id]
      #We come from the creation of a new release from a version which is generic
      @version = Version.find(params[:version_id])
      @version.generic = false
    else
      @version = Version.new
    end
    _form
    @version.logiciel_id = params[:logiciel_id] if params[:logiciel_id]
  end
  
  def new_specific
    @version = Version.find(params[:id])
    _form
  end

  def create
    @version = Version.new(params[:version])
    if @version.save
      flash[:notice] = _('The version %s has been created.') % @version.name
      redirect_to logiciel_path(@version.logiciel)
    else
      _form
      render :action => 'new'
    end
  end

  def edit
    @version = Version.find(params[:id])
    _form
  end

  def update
    @version = Version.find(params[:id])
    if @version.update_attributes(params[:version])
      flash[:notice] = _('The version %s has been updated.') % @version.full_name
      redirect_to version_path(@version)
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    Version.find(params[:id]).destroy
    redirect_back
  end

  private
  def _form
    @logiciels = Logiciel.find_select
    @groupes = Groupe.find_select
    @socles = Socle.find_select
    @contracts = Contract.find_select(Contract::OPTIONS)
  end

  def _panel
    @count = {}
    @clients = Client.find_select(:conditions => 'clients.inactive = 0')
    @count[:versions] = Version.count
  end

end
