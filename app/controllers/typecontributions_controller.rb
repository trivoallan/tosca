#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class TypecontributionsController < ApplicationController
  def index
    @typecontribution_pages, @typecontributions = paginate :typecontributions, :per_page => 10
    render :action => 'list'
  end

  def show
    @typecontribution = Typecontribution.find(params[:id])
  end

  def new
    @typecontribution = Typecontribution.new
  end

  def create
    @typecontribution = Typecontribution.new(params[:typecontribution])
    if @typecontribution.save
      flash[:notice] = 'Typecontribution was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @typecontribution = Typecontribution.find(params[:id])
  end

  def update
    @typecontribution = Typecontribution.find(params[:id])
    if @typecontribution.update_attributes(params[:typecontribution])
      flash[:notice] = 'Typecontribution was successfully updated.'
      redirect_to :action => 'show', :id => @typecontribution
    else
      render :action => 'edit'
    end
  end

  def destroy
    Typecontribution.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
