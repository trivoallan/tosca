#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class LogicielsController < ApplicationController
  # public access to the list
  before_filter :login_required, :except =>
    [:index,:show,:auto_complete_for_logiciel_nom]

  helper :filters, :paquets, :demandes, :competences, :contributions

  # auto completion in 2 lines, yeah !
  auto_complete_for :logiciel, :nom

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

    options = { :per_page => 10, :order => 'logiciels.nom',
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
        [:software, 'logiciels.nom', :like ],
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
    if @logiciel.save
      flash[:notice] = _('The software %s has been created succesfully.') % @logiciel.nom
      redirect_to logiciels_path
    else
      _form and render :action => 'new'
    end
  end

  def edit
    @logiciel = Logiciel.find(params[:id])
    _form
  end

  def update
    @logiciel = Logiciel.find(params[:id])
    if @logiciel.update_attributes(params[:logiciel])
      flash[:notice] = _('The software %s has been updated successfully.') % @logiciel.nom
      redirect_to logiciels_path
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    @logiciel = Logiciel.find(params[:id])
    @logiciel.destroy
    flash[:notice] = _('The software %s has been successfully deleted.') % @logiciel.nom
    redirect_to logiciels_path
  end


private
  def _form
    order_by_name = { :order => 'nom' }
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
                       Binaire.count, Logiciel.count)
  end

end
