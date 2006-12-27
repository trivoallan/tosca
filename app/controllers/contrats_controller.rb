#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class ContratsController < ApplicationController
  helper :clients,:engagements,:ingenieurs

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @contrat_pages, @contrats = paginate :contrats, :per_page => 10,
    :include => [:client]
  end

  def show
    @contrat = Contrat.find(params[:id], :include => [:ingenieurs])
  end

  def new
    @contrat = Contrat.new
    _form
  end

  def create
    @contrat = Contrat.new(params[:contrat])
    if @contrat.save
      @contrat.engagements = Engagement.find(@params[:engagement_ids]) if @params[:engagement_ids]
      @contrat.ingenieurs = Ingenieur.find(@params[:ingenieur_ids]) if @params[:ingenieur_ids]
      @contrat.save

      flash[:notice] = 'Contrat was successfully created.'
      redirect_to :action => 'list'
    else
      _form
      render :action => 'new'
    end
  end

  def edit
    @contrat = Contrat.find(params[:id])
    _form
  end

  def update
    @contrat = Contrat.find(params[:id])
    if @params[:engagement_ids]
      @contrat.engagements = Engagement.find(@params[:engagement_ids]) 
    else
      @contrat.engagements = []
      @contrat.errors.add_on_empty('engagements') 
    end
    @contrat.ingenieurs = Ingenieur.find(@params[:ingenieur_ids]) if @params[:ingenieur_ids]

    if @params[:engagement_ids] and @contrat.update_attributes(params[:contrat])
      flash[:notice] = 'Contrat mis à jour correctement.'
      redirect_to :action => 'show', :id => @contrat
    else
      _form
      render :action => 'edit'
    end
  end

  def destroy
    Contrat.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

private
  def _form
    @clients = Client.find_all
    @informations = Engagement.find_all_by_typedemande_id(1, :order => 'severite_id')
    @anomalies = Engagement.find_all_by_typedemande_id(2, :order => 'severite_id')
    @evolutions = Engagement.find_all_by_typedemande_id(3, :order => 'severite_id')
    @ingenieurs = Ingenieur.find_ossa(:all)
  end

end
