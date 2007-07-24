#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class TypecontributionsController < ApplicationController
  def index
    @typecontribution_pages, @typecontributions = paginate :typecontributions, :per_page => 10
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
      flash[:notice] = _("A new type of contribution was successfully created.")
      redirect_to typecontributions_path
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
      flash[:notice] = _("A Type of contribution was successfully updated.")
      redirect_to typecontribution_path(@typecontribution)
    else
      render :action => 'edit'
    end
  end

  def destroy
    Typecontribution.find(params[:id]).destroy
    redirect_to typecontributions_path
  end
end
