class AppelsController < ApplicationController
  helper :filters

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    # init
    options = { :per_page => 15, :order => 'appels.debut', :include => 
      [:beneficiaire,:ingenieur,:contrat] }
    conditions = Appel.filters(params)

    # query
    options[:conditions] = conditions.join(' AND ') unless conditions.empty?
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
    _form
  end

  def create
    @appel = Appel.new(params[:appel])
    if @appel.save
      flash[:notice] = 'l\'Appel a été créé.'
      redirect_to :action => 'list'
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
    redirect_to :action => 'list'
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
    options = { :conditions => [ 'contrats.astreinte=?', 1 ], 
      :include => Contrat::INCLUDE, :order => 'clients.nom' }
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
    @count[:duree_totale] = 0 # TODO 
    @count[:demandes] = 0 # TODO 
  end

end
