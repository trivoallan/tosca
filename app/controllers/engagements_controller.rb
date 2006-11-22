class EngagementsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @engagement_pages, @engagements = paginate :engagements, :per_page => 20, :order => "typedemande_id, severite_id"
  end

  def show
    @engagement = Engagement.find(params[:id])
  end

  def new
    @engagement = Engagement.new
    @supports = Support.find_all
    @typedemandes = Typedemande.find_all
    @severites = Severite.find_all
  end

  def create
    @engagement = Engagement.new(params[:engagement])
    if @engagement.save
      flash[:notice] = 'Engagement was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @engagement = Engagement.find(params[:id])
    @supports = Support.find_all
    @typedemandes = Typedemande.find_all
    @severites = Severite.find_all
  end

  def update
    @engagement = Engagement.find(params[:id])
    if @engagement.update_attributes(params[:engagement])
      flash[:notice] = 'Engagement was successfully updated.'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    Engagement.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
