class UrlreversementsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @urlreversement_pages, @urlreversements = paginate :urlreversements, :per_page => 10
  end

  def show
    @urlreversement = Urlreversement.find(params[:id])
  end

  def new
    @urlreversement = Urlreversement.new
    _form
  end

  def create
    @urlreversement = Urlreversement.new(params[:urlreversement])
    if @urlreversement.save
      flash[:notice] = 'Urlreversement was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @urlreversement = Urlreversement.find(params[:id])
    _form
  end

  def _form
    @correctifs = Correctif.find_all
  end

  def update
    @urlreversement = Urlreversement.find(params[:id])
    if @urlreversement.update_attributes(params[:urlreversement])
      flash[:notice] = 'Urlreversement was successfully updated.'
      redirect_to :action => 'show', :id => @urlreversement
    else
      render :action => 'edit'
    end
  end

  def destroy
    Urlreversement.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
