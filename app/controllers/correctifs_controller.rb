#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class CorrectifsController < ApplicationController

  model :contribution

  helper :reversements, :demandes, :paquets, :binaires, :logiciels

  before_filter :verifie, :only => 
    [ :show, :edit, :update, :destroy ]

  def verifie
    super(Correctif)
  end

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    # @count = Correctif.count
    conditions = nil
    @logiciels = Logiciel.find(:all)
    @count = Contribution.count
    scope_filter do
      @correctif_pages, @correctifs = paginate :contributions, :per_page => 10
    end
  end

  def show
    @correctif = Contribution.find(params[:id])
  end

  def new
    @correctif = Contribution.new
    @urlreversement = Urlreversement.new
    _form
  end

  def create
    @correctif = Contribution.new(params[:correctif])
    if @correctif.save
      flash[:notice] = 'Le correctif suivant a bien été crée : </br><i>'+@correctif.description+'</i>'
      if params[:urlreversement]
        urlreversement = Urlreversement.new(params[:urlreversement])
        urlreversement.correctif = @correctif
        urlreversement.save
        flash[:notice] << '</br>L\'url a également été enregistrée.'
      end
      redirect_to :action => 'list'
    else
      new and render :action => 'new'
    end
  end

  def edit
    @correctif = Contribution.find(params[:id])
    _form
  end

  def update
    @correctif = Contribution.find(params[:id])
    # @correctif.paquets = Paquet.find(@params[:paquet_ids]) if @params[:paquet_ids]
    @correctif.demandes = Demande.find(@params[:demande_ids]) if @params[:demande_ids]
    if @correctif.update_attributes(params[:correctif])
      flash[:notice] = 'Le correctif suivant a bien été mis à jour : </br><i>'+@correctif.description+'</i>'
      redirect_to :action => 'list'
    else
      _form
      render :action => 'edit'
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


  private
  def _form
    @logiciels = Logiciel.find_all
    @paquets = @correctif.paquets || []
    @binaires = @correctif.binaires || []
    @etatreversements = Etatreversement.find_all
    @ingenieurs = Ingenieur.find_all
    @typecontributions = Typecontribution.find_all
  end

end
