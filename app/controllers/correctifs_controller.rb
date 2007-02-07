#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class CorrectifsController < ApplicationController
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

    @count = Correctif.count
    @correctif_pages, @correctifs = paginate :correctifs, :per_page => 10,
    :conditions => conditions
  end

  def show
    @correctif = Correctif.find(params[:id])
  end

  def new
    @correctif = Correctif.new
    _form
  end

  def create
    @correctif = Correctif.new(params[:correctif])
    if @correctif.save
      flash[:notice] = 'Le correctif suivant a bien été crée : </br><i>'+@correctif.description+'</i>'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @correctif = Correctif.find(params[:id])
    _form
  end

  def update
    @correctif = Correctif.find(params[:id])
#    @correctif.paquets = Paquet.find(@params[:paquet_ids]) if @params[:paquet_ids]
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
    Correctif.find(params[:id]).destroy
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
  end

end
