class AppelsController < ApplicationController
  helper :filters, :export, :demandes, :clients

  def index
    options = { :per_page => 15, :order => 'appels.debut', :include =>
      [:beneficiaire,:ingenieur,:contrat,:demande] }
    conditions = []


    if params.has_key? :filters
      session[:calls_filters] = Filters::Calls.new(params[:filters])
    end

    conditions = nil
    if session.data.has_key? :calls_filters
      calls_filters = session[:calls_filters]
      # Specification of a filter f :
      #   [ field, database field, operation ]
      # All the fields must be coherent with lib/filters.rb related Struct.
      conditions = Filters.build_conditions(calls_filters, [
        [:ingenieur_id, 'appels.ingenieur_id', :equal ],
        [:beneficiaire_id, 'appels.beneficiaire_id', :equal ],
        [:contrat_id, 'appels.contrat_id', :equal ],
        [:after, 'appels.debut', :greater_than ],
        [:before, 'appels.fin', :lesser_than ]
      ])
      @filters = calls_filters
      flash[:conditions] = options[:conditions] = conditions
    end

    @appel_pages, @appels = paginate :appels, options
    # panel on the left side. cookies is here for a correct 'back' button
    if request.xhr?
      render :partial => 'calls_list', :layout => false
    else
      _panel
      @partial_for_summary = 'calls_info'
    end
  end

  def create
    @appel = Appel.new(params[:appel])
    if @appel.save
      flash[:notice] = _('The call was successfully created.')
      if @appel.demande
        redirect_to comment_demande_path(@appel.demande)
      else
        redirect_to appels_path
      end
    else
      _form and render :action => 'new'
    end
  end

  def show
    @appel = Appel.find(params[:id])
  end

  def new
    @appel = Appel.new
    @appel.ingenieur = @ingenieur
    @appel.demande_id = params[:id]
    _form
  end

  def edit
    @appel = Appel.find(params[:id])
    _form
  end

  def update
    @appel = Appel.find(params[:id])
    if @appel.update_attributes(params[:appel])
      flash[:notice] = 'l\'appel a été mis à jour.'
      redirect_to appels_path
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    Appel.find(params[:id]).destroy
    redirect_to appels_url
  end

  def ajax_beneficiaires
    return render(:nothing) unless request.xml_http_request?

    # la magie de rails est cassé pour la 1.2.2, en mode production
    # donc je dois le faire manuellement
    # TODO : vérifier pour les versions > 1.2.2 en _production_ (!)
    contrat = Contrat.find(params[:id])
    @beneficiaires =
      contrat.client.beneficiaires.find_select(User::SELECT_OPTIONS)

    render :partial => 'select_beneficiaires', :layout => false and return
  rescue ActiveRecord::RecordNotFound
    render :text => '-'
  end

  private
  # conventions
  def _form
    @ingenieurs = Ingenieur.find_select(User::SELECT_OPTIONS)
    @contrats = Contrat.find_select(Contrat::OPTIONS)
  end

  # variables utilisé par le panneau de gauche
  def _panel
    @count = {}
    _form
    @beneficiaires = Beneficiaire.find_select(User::SELECT_OPTIONS)

    @count[:appels] = Appel.count
    @count[:beneficiaires] = Appel.count 'beneficiaire_id', {}
    @count[:ingenieurs] = Appel.count('ingenieur_id', {})
    @count[:demandes] = Appel.count('demande_id', :distinct => true)
    diff = 'TIME_TO_SEC(TIMEDIFF(fin,debut))'
    @count[:somme] = Appel.sum(diff).to_i
    @count[:moyenne] = Appel.average(diff).to_i
  end


end
