class AppelsController < ApplicationController
  helper :filters, :export, :demandes, :clients

  def index
    list
    render :action => 'list'
  end

  def list
    # init
    options = { :per_page => 15, :order => 'appels.debut', :include => 
      [:beneficiaire,:ingenieur,:contrat,:demande] }
    conditions = []

    # Specification of a filter f :
    # [ namespace, field, database field, operation ]
    conditions = Filters.build_conditions(params, [
       ['filters', 'ingenieur_id', 'appels.ingenieur_id', :equal ],
       ['filters', 'beneficiaire_id', 'appels.beneficiaire_id', :equal ],
       ['filters', 'contrat_id', 'appels.contrat_id', :equal ],
       ['date', 'after', 'appels.debut', :greater_than ],
       ['date', 'before', 'appels.fin', :lesser_than ]
     ])
    flash[:conditions] = options[:conditions] = conditions 

    @appel_pages, @appels = paginate :appels, options   
    # panel on the left side
    if request.xhr? 
      render :partial => 'calls_list', :layout => false
    else
      _panel
      @partial_for_summary = 'calls_info'
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

  def create
    @appel = Appel.new(params[:appel])
    if @appel.save
      flash[:notice] = 'l\'Appel a été créé.'
      if @appel.demande
        redirect_to :action => 'comment', :controller => 'demandes', :id => @appel.demande
      else
        redirect_to :action => 'list'
      end
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
    redirect_to appels_url
  end

  def ajax_beneficiaires
    return render_text('') unless request.xml_http_request? and params[:id]

    # la magie de rails est cassé pour la 1.2.2, en mode production
    # donc je dois le faire manuellement
    # TODO : vérifier pour les versions > 1.2.2 en _production_ (!)
    contrat = Contrat.find(params[:id])
    @beneficiaires = contrat.client.beneficiaires.find_select(Identifiant::SELECT_OPTIONS)

    render :partial => 'select_beneficiaires', :layout => false and return
  rescue ActiveRecord::RecordNotFound
    render_text '-'
  end


  private
  # conventions
  def _form   
    @ingenieurs = Ingenieur.find_select(Identifiant::SELECT_OPTIONS)
    options = { :include => Contrat::INCLUDE, :order => 'clients.nom' }
    @contrats = Contrat.find_select(options)
  end

  # variables utilisé par le panneau de gauche
  def _panel 
    @count = {}
    _form
    @beneficiaires = Beneficiaire.find_select(Identifiant::SELECT_OPTIONS)

    @count[:appels] = Appel.count
    @count[:beneficiaires] = Appel.count('beneficiaire_id')
    @count[:ingenieurs] = Appel.count('ingenieur_id')
    @count[:demandes] = Appel.count('demande_id', :distinct => true)
    diff = 'TIME_TO_SEC(TIMEDIFF(fin,debut))'
    @count[:somme] = Appel.sum(diff).to_i 
    @count[:moyenne] = Appel.average(diff).to_i 
  end

end
