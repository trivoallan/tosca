#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class ContributionsController < ApplicationController
  helper :filters, :demandes, :paquets, :binaires, :export, :urlreversements, :logiciels

  caches_page :feed

  # Show all contribs and who's done 'em
  def experts
    options = { :order => "contributions.ingenieur_id, contributions.etatreversement_id" }
    @contributions = Contribution.find(:all, options)
  end

  def index
    select
    render :action => "select"
  end

  def list
    options = { :order => "created_on DESC" }
    unless params[:id] == 'all'
      @logiciel = Logiciel.find(params[:id])
      options[:conditions] = ['contributions.logiciel_id = ?', @logiciel.id]
    end
    @contribution_pages, @contributions = paginate :contributions, options
  end

  # TODO : c'est pas très rails tout ça (mais c'est moins lent)
  def select
    options = { :conditions =>
      'logiciels.id IN (SELECT DISTINCT logiciel_id FROM contributions)',
      :order => 'logiciels.name ASC' }
    @logiciels = Logiciel.find(:all, options)
  end

  def admin
    conditions = []
    options = { :per_page => 10, :order => 'contributions.updated_on DESC',
      :include => [:logiciel,:etatreversement,:demandes] }

    if params.has_key? :filters
      session[:contributions_filters] =
        Filters::Contributions.new(params[:filters])
    end
    conditions = nil
    if session.data.has_key? :contributions_filters
      contributions_filters = session[:contributions_filters]

      # Specification of a filter f :
      #   [ field, database field, operation ]
      # All the fields must be coherent with lib/filters.rb related Struct.
      conditions = Filters.build_conditions(contributions_filters, [
        [:software, 'logiciels.name', :like ],
        [:contribution, 'contributions.name', :like ],
        [:etatreversement_id, 'contributions.etatreversement_id', :equal ],
        [:ingenieur_id, 'contributions.ingenieur_id', :equal ],
        [:contrat_id, 'demandes.contrat_id', :equal ]
      ])
      @filters = contributions_filters
    end
    flash[:conditions] = options[:conditions] = conditions

    @contribution_pages, @contributions = paginate :contributions, options
    # panel on the left side. cookies is here for a correct 'back' button
    if request.xhr?
      render :partial => 'contributions_admin', :layout => false
    else
      _panel
      @partial_for_summary = 'contributions_info'
    end
  end

  def new
    @contribution = Contribution.new
    @urlreversement = Urlreversement.new
    # we can precise the software with this, see softwares/show for more info
    @contribution.logiciel_id = params[:id]
    @contribution.ingenieur = @ingenieur
    _form
  end

  def create
    @contribution = Contribution.new(params[:contribution])
    if @contribution.save
      flash[:notice] = _('The contribution has been created successfully.')
      _update(@contribution)
      redirect_to contribution_path(@contribution)
    else
      _form and render :action => 'new'
    end
  end

  def edit
    @contribution = Contribution.find(params[:id])
    _form
  end

  def show
    @contribution = Contribution.find(params[:id])
  end

  def update
    @contribution = Contribution.find(params[:id])
    if @contribution.update_attributes(params[:contribution])
      flash[:notice] = _('The contribution has been updated successfully.')
      _update(@contribution)
      redirect_to contribution_path(@contribution)
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    Contribution.find(params[:id]).destroy
    redirect_to contributions_path
  end

  def ajax_paquets
    return render_text('') unless request.xml_http_request? and params[:id]

    # la magie de rails est cassé pour la 1.2.2, en mode production
    # donc je dois le faire manuellement
    # TODO : vérifier pour les versions > 1.2.2 en _production_ (!)
    clogiciel = [ 'paquets.logiciel_id = ?', params[:id].to_i ]
    options = Paquet::OPTIONS.dup
    options[:conditions] = clogiciel
    @paquets = Paquet.find(:all, options)
    options = Binaire::OPTIONS.dup
    options[:conditions] = clogiciel
    @binaires = Binaire.find(:all, options)

    render :partial => 'liste_paquets', :layout => false
  end

  #Spa très REST tout ça !
  # TODO : cache it on a page level
  def feed
    options = { :include => [:etatreversement], :order => "updated_on DESC", :limit => 20 }
    @contributions = Contribution.find(:all, options)
    @feed_description = @feed_title = "Les contributions du 08000Linux"
    @feed_url = "http://" + request.host_with_port + request.request_uri
    response.headers['Content-Type'] = 'application/rss+xml'
    render :action => 'feed', :layout => false
  end

private
  def _form
    @logiciels = Logiciel.find_select
    @paquets = @contribution.paquets || []
    @binaires = @contribution.binaires || []
    @etatreversements = Etatreversement.find_select
    @ingenieurs = Ingenieur.find_select(User::SELECT_OPTIONS)
    @typecontributions = Typecontribution.find_select
  end

  def _panel
    @etatreversements = Etatreversement.find_select
    @ingenieurs = Ingenieur.find_select(User::SELECT_OPTIONS)
    @logiciels = Logiciel.find_select
    @contrats = Contrat.find_select(Contrat::OPTIONS)
    # count
    clogiciels = { :select => 'contributions.logiciel_id', :distinct => true }
    @count = {:contributions => Contribution.count,
      :logiciels => Contribution.count(clogiciels) }
  end

  def _update(contribution)
    urlreversement = params[:urlreversement]
    unless urlreversement.blank?
      urlreversement[:contribution_id] = contribution.id
      Urlreversement.create(urlreversement)
    end
    contribution.reverse_le = nil if params[:contribution][:reverse] == '0'
    contribution.cloture_le = nil if params[:contribution][:clos] == '0'
    expire_page :action => 'feed'
    contribution.save
  end
end
