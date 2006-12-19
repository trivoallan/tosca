#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class ContratsController < ApplicationController
  helper :clients,:engagements

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
    @contrat = Contrat.find(params[:id])
  end

  def new
    @contrat = Contrat.new
    common_form
  end

  def create
    @contrat = Contrat.new(params[:contrat])
    if @contrat.save
      if @params[:engagement_ids]
        @contrat.engagements = Engagement.find(@params[:engagement_ids]) 
      end
      @contrat.save

      flash[:notice] = 'Contrat was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @contrat = Contrat.find(params[:id])
    common_form
  end

  def update
    @contrat = Contrat.find(params[:id])
    if @params[:engagement_ids]
      @contrat.engagements = Engagement.find(@params[:engagement_ids]) 
    else
      @contrat.engagements = []
      @contrat.errors.add_on_empty('engagements') 
    end

    if @params[:engagement_ids] and @contrat.update_attributes(params[:contrat])
      flash[:notice] = 'Contrat mis à jour correctement.'
      redirect_to :action => 'show', :id => @contrat
    else
      render :action => 'edit'
    end
  end

  def destroy
    Contrat.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

private
  def common_form
    @clients = Client.find_all
    @engagements = Engagement.find(:all, :order => "typedemande_id, severite_id")
  end

end
