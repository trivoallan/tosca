#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class ContributionsController < ApplicationController

  # je ne sais pas s'il sont tous nécessaire : 
  # helper :reversements, :demandes, :paquets, :binaires, :logiciels
  helper                  :demandes, :paquets, :binaires

  before_filter :verifie, :only => [ :show, :edit, :update, :destroy ] 

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def verifie
    super(Contribution)
  end

  def index
    select and render :action => 'select'
  end

  def select
    _panel
    #flash[:notice] = 'test'
    @logiciels = Contribution.find(:all, :order => 'reverse_le').collect{|c| c.logiciel }.uniq
    @partial_for_summary = 'panel'
  end

  def list
    flash[:notice]= flash[:notice]
    return redirect_to :action => 'select' unless params[:id]
    unless params[:id] == 'all'
      @logiciel = Logiciel.find(params[:id])
      conditions = ["logiciel_id = ?", @logiciel.id]
    else
      conditions = nil
    end
    #scope_filter do
      @contribution_pages, @contributions = paginate :contributions, :per_page => 10,
      :order => "created_on DESC", :conditions => conditions
    #end
  end

  def admin
    # @count = Contribution.count
    conditions = nil
    _panel
    @contribution_pages, @contributions = paginate :contributions, :per_page => 10, 
    :order => 'updated_on DESC'
    @partial_for_summary = 'panel'
  end

  def new
    @contribution = Contribution.new
    @urlreversement = Urlreversement.new
    # pour préciser le type dès la création
    @contribution.logiciel_id = params[:id]
    _form
  end

  def create
    @contribution = Contribution.new(params[:contribution])
    if @contribution.save
      flash[:notice] = 'La contribution suivante a bien été créee : </br><i>'+@contribution.description+'</i>'
      if params[:urlreversement]
        urlreversement = Urlreversement.new(params[:urlreversement])
        urlreversement.contribution = @contribution
        urlreversement.save
        flash[:notice] << '</br>L\'url a également été enregistrée.'
      end
      redirect_to :action => 'list'
    else
      new and render :action => 'new'
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
    # @contribution.paquets = Paquet.find(@params[:paquet_ids]) if @params[:paquet_ids]
    @contribution.demandes = Demande.find(@params[:demande_ids]) if @params[:demande_ids]
    if @contribution.update_attributes(params[:contribution])
      flash[:notice] = 'La contribution suivante a bien été mise à jour : </br><i>'+@contribution.description+'</i>'
      redirect_to :action => 'list'
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    Contribution.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def ajax_paquets
    render_text('') and return unless request.xml_http_request? and params[:id]

    logiciel = Logiciel.find(params[:id].to_i)
    @paquets = logiciel.paquets.find(:all, Paquet::OPTIONS)
    @binaires = logiciel.binaires.find(:all, Binaire::OPTIONS) 

    render :partial => 'liste_paquets', :layout => false
  end

  def to_s
    nom
  end

private

  def _form
    @logiciels = Logiciel.find_all
    @paquets = @contribution.paquets || []
    @binaires = @contribution.binaires || []
    @etatreversements = Etatreversement.find_all
    @ingenieurs = Ingenieur.find_all
    @typecontributions = Typecontribution.find_all
  end

  def _panel
    @etatreversements = Etatreversement.find(:all)
    @logiciels = Logiciel.find(:all)
    @clients = Client.find(:all)
    # count
    @count = {:contributions => Contribution.count }
    count_logiciels = { :select => 'contributions.logiciel_id' }
    @count[:logiciels] = Contribution.count(count_logiciels)
  end

end

