#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class CompetencesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @competence_pages, @competences = paginate :competences, :per_page => 50
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
