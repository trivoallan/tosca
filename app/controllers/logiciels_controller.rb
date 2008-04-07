#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class LogicielsController < ApplicationController
  helper :filters, :paquets, :demandes, :competences, :contributions, :licenses

  # Not used for the moment
  # auto_complete_for :logiciel, :name

  # ajaxified list
  def index
    scope = nil
    @title = _('List of softwares')
    if @beneficiaire
      unless params['active'] == '0'
        scope = :supported
        @title = _('List of your supported softwares')
      end
    end

    options = { :per_page => 10, :order => 'logiciels.name',
                :include => [:groupe,:competences] }
    conditions = []

    if params.has_key? :filters
      session[:softwares_filters] = Filters::Softwares.new(params[:filters])
    end
    conditions = nil
    if session.data.has_key? :softwares_filters
      softwares_filters = session[:softwares_filters]

      # we do not want an include since it's only for filtering.
      unless softwares_filters['contrat_id'].blank?
        options[:joins] = 'INNER JOIN paquets ON paquets.logiciel_id=logiciels.id'
      end

      # Specification of a filter f :
      #   [ field, database field, operation ]
      # All the fields must be coherent with lib/filters.rb related Struct.
      conditions = Filters.build_conditions(softwares_filters, [
        [:software, 'logiciels.name', :like ],
        [:description, 'logiciels.description', :like ],
        [:groupe_id, 'logiciels.groupe_id', :equal ],
        [:competence_id, 'competences_logiciels.competence_id', :equal ],
        [:contrat_id, ' paquets.contrat_id', :in ]
      ])
      @filters = softwares_filters
    end
    flash[:conditions] = options[:conditions] = conditions

    # optional scope, for customers
    begin
      Logiciel.set_scope(@beneficiaire.contrat_ids) if scope
      @logiciel_pages, @logiciels = paginate :logiciels, options
    ensure
      Logiciel.remove_scope if scope
    end

    # panel on the left side. cookies is here for a correct 'back' button
    if request.xhr?
      render :partial => 'softwares_list', :layout => false
    else
      _panel
      @partial_for_summary = 'softwares_info'
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
      redirect_to logiciels_path
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


private
  def _form
    order_by_name = { :order => 'name' }
    @competences = Competence.find(:all, order_by_name)
    @groupes = Groupe.find(:all, order_by_name)
    @licenses = License.find(:all, order_by_name)
  end

  def _panel
    @contrats = Contrat.find_select(Contrat::OPTIONS) if @ingenieur
    @technologies = Competence.find_select
    @groupes = Groupe.find_select

    stats = Struct.new(:technologies, :sources, :binaries, :softwares)
    @count = stats.new(Competence.count, Paquet.count,
                       Binaire.count(:include => :paquet), Logiciel.count)
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
