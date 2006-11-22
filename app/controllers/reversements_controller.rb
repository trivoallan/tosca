class ReversementsController < ApplicationController

  helper :correctifs

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @reversement_pages, @reversements = paginate :reversements, :per_page => 10
  end

  def show
    @reversement = Reversement.find(params[:id])
  end

  def new
    @reversement = Reversement.new
    _form
  end

  def create
    @reversement = Reversement.new(params[:reversement])
    if @reversement.save
      flash[:notice] = 'Reversement was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @reversement = Reversement.find(params[:id])
    _form
  end

  def update
    @reversement = Reversement.find(params[:id])
    if @reversement.update_attributes(params[:reversement])
      flash[:notice] = 'Reversement was successfully updated.'
      redirect_to :action => 'show', :id => @reversement
    else
      render :action => 'edit'
    end
  end

  def destroy
    Reversement.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  private
  def _form
    @correctifs = Correctif.find_all
  end

  def scope_beneficiaire
    if @beneficiaire
      conditions = [ "beneficiaires.client_id = ?", benef.client.id ]
      joins = 'INNER JOIN demandes ON demandes.correctif_id = reversements.correctif_id ' 
      joins << 'INNER JOIN beneficiaires ON demandes.beneficiaire_id = beneficiaires.id '
      Reversement.with_scope({ :find => { 
                               :conditions => conditions,
                               :joins => joins
                             },
                        }) { yield }
    else
      yield
    end
  end

end
