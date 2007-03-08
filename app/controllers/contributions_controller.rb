#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class ContributionsController < ApplicationController
  helper :demandes, :paquets, :binaires

  # auto completion in 2 lines, yeah !
  auto_complete_for :logiciel, :nom

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  before_filter :verifie, :only => [ :show, :edit, :update, :destroy ]
  
  def verifie
    super(Contribution)
  end

  def index
    select and render :action => 'select'
  end

  def select
    _panel
    # TODO c'est lent. Il faut un DISTINCT et repenser ce finder
    logiciels = Contribution.find(:all, :order => 'reverse_le')
    @logiciels = logiciels.collect{ |c| c.logiciel }.uniq
  end

  def list
    flash[:notice]= flash[:notice]
    return redirect_to(:action => 'select') unless params[:id]
    unless params[:id] == 'all'
      @logiciel = Logiciel.find(params[:id])
      conditions = ['logiciel_id = ?', @logiciel.id]
    else
      conditions = nil
    end
    @contribution_pages, @contributions = paginate :contributions, 
    :per_page => 10, :order => "created_on DESC", :conditions => conditions
  end

  def admin
    conditions = []
    options = { :per_page => 25, 
      :include => [:logiciel,:etatreversement,:demandes] }

    params['logiciel'].each_pair { |key, value|
      conditions << " logiciels.#{key} LIKE '%#{value}%'" if value != ''
    } if params['logiciel']
    if params['filters']
      params['filters'].each_pair { |key, value|
        unless value == '' or key.intern == :client_id
          conditions << " #{key}=#{value} " 
        end
      } 
      scope_client(params['filters']['client_id'])
      Paquet.set_scope(session[:contrat_ids])
      Demande.set_scope(params['filters']['client_id'])
    end
    params['contribution'].each_pair { |key, value|
      conditions << " contributions.#{key} LIKE '%#{value}%'" if value != ''
    } if params['contribution']

    options[:conditions] = conditions.join(' AND ') unless conditions.empty?

    @contribution_pages, @contributions = paginate :contributions, options
    # panel on the left side
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
    # pour préciser le type dès la création
    @contribution.logiciel_id = params[:id]
    _form
  end

  def create
    @contribution = Contribution.new(params[:contribution])
    if @contribution.save
      flash[:notice] = 'La contribution suivante a bien été créee : ' + 
        '</br><i>'+@contribution.description+'</i>'
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
    if @params[:demande_ids]
      @contribution.demandes = Demande.find(@params[:demande_ids]) 
    end
    if @contribution.update_attributes(params[:contribution])
      flash[:notice] = 'La contribution suivante a bien été mise à jour ' + 
        ': </br><i>'+@contribution.description+'</i>'
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
    return redirect_to_home unless request.xml_http_request? and params[:id]

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
    @etatreversements = Etatreversement.find_select
    @logiciels = Logiciel.find_select
    @clients = Client.find_select
    # count
    count_logiciels = { :select => 'contributions.logiciel_id' }
    @count = {:contributions => Contribution.count,
      :logiciels => Contribution.count(count_logiciels) }
  end

end

