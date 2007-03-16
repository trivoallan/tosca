#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class ContributionsController < ApplicationController
  helper :filters, :demandes, :paquets, :binaires

  # auto completion in 2 lines, yeah !
  auto_complete_for :logiciel, :nom

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }
  def index
    select and render :action => 'select'
  end

  # TODO : c'est pas très rails tout ça (mais c'est moins lent)
  def select
    @logiciels = Logiciel.find_by_sql 'SELECT logiciels.* FROM logiciels ' + 
      'WHERE logiciels.id IN (SELECT DISTINCT logiciel_id FROM contributions)'
  end

  def list
    flash[:notice]= flash[:notice]
    return redirect_to(:action => 'select') unless params[:id]
    options = { :per_page => 10, :order => "created_on DESC" }
    unless params[:id] == 'all'
      @logiciel = Logiciel.find(params[:id])
      options[:conditions] = ['logiciel_id = ?', @logiciel.id]
    end
    @contribution_pages, @contributions = paginate :contributions, options
  end

  def admin
    conditions = []
    options = { :per_page => 10, :order => 'contributions.updated_on DESC', 
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
      # TODO : trouver un moyen plus rapide
      if params['filters']['client_id'] != ''
        client = Client.find(params['filters']['client_id']) 
        conditions << ' ( demandes.beneficiaire_id IN (' + 
          client.beneficiaire_ids + ' ) OR paquets.contrat_id IN (' + 
          client.contrat_ids + '))'
        options[:include] << :paquets
      end
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
    @contribution.logiciel_id = params[:id] if params[:id]
    _form
  end

  def create
    @contribution = Contribution.new(params[:contribution])
    @urlreversement = Urlreversement.new(params[:urlreversement])
    if @contribution.save
      flash[:notice] = 'La contribution suivante a bien été créee : ' + 
        '</br><i>'+@contribution.description+'</i>'
      @urlreversement.contribution = @contribution
      @urlreversement.save
      flash[:notice] << '</br>L\'url a également été enregistrée.'
      redirect_to :action => 'list'
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
    return render_text('') unless request.xml_http_request? and params[:id]

    # la magie de rails est cassé pour la 1.2.2, en mode production
    # donc je dois le faire manuellement
    # TODO : vérifier pour les versions > 1.2.2 en _production_ (!)
    clogiciel = [ 'paquets.logiciel_id = ?', params[:id].to_i ]
    options = Paquet::OPTIONS.dup
    options[:conditions] = clogiciel
    @paquets = Paquet.find(:all, options)
    options = Binaire::OPTIONS
    options[:conditions] = clogiciel
    @binaires = Binaire.find(:all, options) 

    render :partial => 'liste_paquets', :layout => false
  end

private
  def _form
    @logiciels = Logiciel.find_select
    @paquets = @contribution.paquets || []
    @binaires = @contribution.binaires || []
    @etatreversements = Etatreversement.find_select
    @ingenieurs = Ingenieur.find_select(Identifiant::SELECT_OPTIONS)
    @typecontributions = Typecontribution.find_select
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

