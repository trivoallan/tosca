#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class ContratsController < ApplicationController
  helper :clients,:engagements,:ingenieurs

  def index
    @contrat_pages, @contrats = paginate :contrats, :per_page => 10,
    :include => [:client]
    render :action => 'list'
  end

  def show
    @contrat = Contrat.find(params[:id], :include => [:ingenieurs])
  end

  def new
    @contrat = Contrat.new
    @contrat.client_id = params[:id]
    _form
  end

  def create
    @contrat = Contrat.new(params[:contrat])
    if @contrat.save
      flash[:notice] = 'Contrat was successfully created.'
      redirect_to :action => 'list'
    else
      _form and render :action => 'new'
    end
  end

  def edit
    @contrat = Contrat.find(params[:id])
    _form
  end

  def update
    @contrat = Contrat.find(params[:id])
    if @contrat.update_attributes(params[:contrat])
      flash[:notice] = 'Contrat mis à jour correctement.'
      redirect_to :action => 'show', :id => @contrat
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    Contrat.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

private
  def _form
    @clients = Client.find_select
    @engagements = Engagement.find(:all, Engagement::OPTIONS)
    @ingenieurs = Ingenieur.find_select(Identifiant::SELECT_OPTIONS)
  end
end
