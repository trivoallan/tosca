class CorrectifsController < ApplicationController

  helper :reversements, :demandes

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
  end

  def update
    @correctif = Correctif.find(params[:id])
    @logiciels = Logiciel.find_all
    @correctif.paquets = Paquet.find(@params[:paquet_ids]) if @params[:paquet_ids]
    @correctif.demandes = Demande.find(@params[:demande_ids]) if @params[:demande_ids]
    if @correctif.update_attributes(params[:correctif])
      flash[:notice] = 'Le correctif suivant a bien été mis à jour : </br><i>'+@correctif.description+'</i>'
      redirect_to :action => 'list', :id => @correctif
    else
      render :action => 'edit'
    end
  end

  def destroy
    Correctif.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  private
  def scope_beneficiaire
    if @beneficiaire
      conditions = [ "beneficiaires.client_id = ?", @beneficiaire.client_id ]
      Correctif.with_scope({ :find => { 
                               :conditions => conditions,
                               :joins => 'INNER JOIN demandes ON ' + 
                                 'demandes.correctif_id = correctifs.id ' +
                                 'INNER JOIN beneficiaires ON ' + 
                                 'demandes.beneficiaire_id = beneficiaires.id '
                             },
                        }) { yield }
    else
      yield
    end
  end

end
