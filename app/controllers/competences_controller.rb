#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class CompetencesController < ApplicationController
  def index
    @competence_pages, @competences = paginate :competences, :per_page => 50
    render :action => 'list'
  end

  def show
    @competence = Competence.find(params[:id])
  end

  def new
    @competence = Competence.new
  end

  def create
    @competence = Competence.new(params[:competence])
    if @competence.save
      flash[:notice] = 'Competence was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @competence = Competence.find(params[:id])
  end

  def update
    @competence = Competence.find(params[:id])
    if @competence.update_attributes(params[:competence])
      flash[:notice] = 'Competence was successfully updated.'
      redirect_to :action => 'show', :id => @competence
    else
      render :action => 'edit'
    end
  end

  def destroy
    Competence.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
