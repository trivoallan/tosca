class LogicielsController < ApplicationController
  helper :filters, :versions, :demandes, :competences, :contributions, :licenses

  # Not used for the moment
  # auto_complete_for :logiciel, :name

  # ajaxified list
  def index
    scope = nil
    @title = _('List of software')
    if @beneficiaire && params['active'] != '0'
      scope = :supported
      @title = _('List of your supported software')
    end

    options = { :per_page => 10, :order => 'logiciels.name', :include => [:groupe] }
    conditions = []

    if params.has_key? :filters
      session[:software_filters] = Filters::Software.new(params[:filters])
    end
    conditions = nil
    software_filters = session[:software_filters]
    if software_filters
      # we do not want an include since it's only for filtering.
      unless software_filters['contract_id'].blank?
        options[:joins] = 'INNER JOIN versions ON versions.logiciel_id=logiciels.id'
      end

      # Specification of a filter f :
      #   [ field, database field, operation ]
      # All the fields must be coherent with lib/filters.rb related Struct.
      conditions = Filters.build_conditions(software_filters, [
        [:software, 'logiciels.name', :like ],
        [:description, 'logiciels.description', :like ],
        [:groupe_id, 'logiciels.groupe_id', :equal ],
        [:contract_id, ' versions.contract_id', :in ]
      ])
      @filters = software_filters
    end
    flash[:conditions] = options[:conditions] = conditions

    # optional scope, for customers
    begin
      Logiciel.set_scope(@beneficiaire.contract_ids) if scope
      @logiciel_pages, @logiciels = paginate :logiciels, options
    ensure
      Logiciel.remove_scope if scope
    end

    # panel on the left side. cookies is here for a correct 'back' button
    if request.xhr?
      render :partial => 'software_list', :layout => false
    else
      _panel
      @partial_for_summary = 'software_info'
    end
  end

  def show
    @logiciel = Logiciel.find(params[:id])
    if @beneficiaire
      @demandes = @beneficiaire.demandes.find(:all, :conditions =>
                                              ['demandes.logiciel_id=?', params[:id]])
    else
      @demandes = Demande.find(:all, :conditions =>
                               ['demandes.logiciel_id=?',params[:id]])
    end
  end

  def card
    @logiciel = Logiciel.find(params[:id])
  end

  def new
    @logiciel = Logiciel.new
    _form
  end

  def create
    @logiciel = Logiciel.new(params[:logiciel])
    if @logiciel.save and add_logo
      flash[:notice] = _('The software %s has been created succesfully.') % @logiciel.name
      redirect_to logiciel_path(@logiciel)
    else
      add_image_errors
      _form and render :action => 'new'
    end
  end

  def edit
    @logiciel = Logiciel.find(params[:id])
    _form
  end

  def update
    @logiciel = Logiciel.find(params[:id])
    if @logiciel.update_attributes(params[:logiciel]) and add_logo
      flash[:notice] = _('The software %s has been updated successfully.') % @logiciel.name
      redirect_to logiciel_path(@logiciel)
    else
      add_image_errors
      _form and render :action => 'edit'
    end
  end

  def destroy
    @logiciel = Logiciel.find(params[:id])
    @logiciel.destroy
    flash[:notice] = _('The software %s has been successfully deleted.') % @logiciel.name
    redirect_to logiciels_path
  end

  def ajax_update_tags
    @logiciel = Logiciel.find(:first, :conditions => { :name => params["logiciel"]["name"] } )
    @competences_check = Competence.find(params["logiciel"]["competence_ids"]) unless params["logiciel"]["competence_ids"] == [""]
    render :partial => 'logiciels/tags', :layout => false
  end

private
  def _form
    @competences = Competence.find_select
    @groupes = Groupe.find_select
    @licenses = License.find_select
  end

  def _panel
    @contracts = Contract.find_select(Contract::OPTIONS) if @ingenieur
    @technologies = Competence.find_select
    @groupes = Groupe.find_select

    stats = Struct.new(:technologies, :versions, :software)
    @count = stats.new(Competence.count, Version.count, Logiciel.count)
  end

  def add_logo
    image = params[:image]
    unless image.nil? || image[:image].blank?
      image[:description] = @logiciel.name
      @logiciel.image = Image.new(image)
      return @logiciel.image.save
    end
    return true
  end

  # because :save resets @logiciel.errors
  def add_image_errors
    unless @logiciel.image.nil?
      @logiciel.image.errors.each do |attr, msg|
        @logiciel.errors.add :image, msg
      end
    end
  end


end
