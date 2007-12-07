#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class EngagementsController < ApplicationController
  def index
    @engagement_pages, @engagements = paginate :engagements,
    :per_page => 20, :order => "typedemande_id, severite_id",
    :include => [:typedemande,:severite]
  end

  def show
    @engagement = Engagement.find(params[:id])
  end

  def new
    @engagement = Engagement.new
    _form
  end

  def create
    @engagement = Engagement.new(params[:engagement])
    if @engagement.save
      flash[:notice] = 'Engagement was successfully created.'
      redirect_to engagements_path
    else
      _form
      render :action => 'new'
    end
  end

  def edit
    @engagement = Engagement.find(params[:id])
    _form
  end

  def update
    @engagement = Engagement.find(params[:id])
    if @engagement.update_attributes(params[:engagement])
      flash[:notice] = 'Engagement was successfully updated.'
      redirect_to engagements_path
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    Engagement.find(params[:id]).destroy
    redirect_to engagements_path
  end

  private
  def _form
    @typedemandes = Typedemande.find_select
    @severites = Severite.find_select
  end
end
