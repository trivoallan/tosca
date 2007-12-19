#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class CompetencesController < ApplicationController
  def index
    options = { :per_page => 50, :order => 'competences.name' }
    @competence_pages, @competences = paginate :competences, options
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
      flash[:notice] = _('Skill was successfully created.')
      redirect_to competences_path
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
      flash[:notice] = _('Skill was successfully updated.')
      redirect_to competence_path(@competence)
    else
      render :action => 'edit'
    end
  end

  def destroy
    Competence.find(params[:id]).destroy
    redirect_to competences_path
  end
end
