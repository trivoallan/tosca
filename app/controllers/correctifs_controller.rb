#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class CorrectifsController < ApplicationController

  helper :reversements, :demandes, :paquets

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
    @correctif.paquets = Paquet.find(@params[:paquet_ids]) if @params[:paquet_ids]
    @correctif.demandes = Demande.find(@params[:demande_ids]) if @params[:demande_ids]
    if @correctif.update_attributes(params[:correctif])
      flash[:notice] = 'Le correctif suivant a bien été mis à jour : </br><i>'+@correctif.description+'</i>'
      redirect_to :action => 'list', :id => @correctif
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
    render_text('') and return unless request.xml_http_request? and @params[:id]

    
    @paquets = Paquet.find_all_by_logiciel_id\
    (@params[:id].to_i, :order => Paquet::ORDER, :include => Paquet::INCLUDE)

    render :partial => "liste_paquets", :layout => false
  end

  private
  def _form
    @logiciels = Logiciel.find_all
    @paquets = @correctif.paquets || []
  end

  # Scope recopié dans le reporting (report_evolution
  # TODO : trouver une façon de faire unique !
  def scope_beneficiaire
    if @beneficiaire
      ids = @beneficiaire.client.contrats.collect{|c| c.id}.join(',')
      conditions = [ "paquets.contrat_id IN (#{ids})" ]
      Correctif.with_scope({ :find => { 
                               :conditions => conditions,
                               :joins => 'INNER JOIN correctifs_paquets cp ON ' + 
                                 'cp.correctif_id = correctifs.id ' +
                                 'INNER JOIN paquets ON ' + 
                                 'cp.paquet_id = paquet.id '
                             },
                        }) { yield }
    else
      yield
    end
  end

end
