class SeveritesController < ApplicationController

  def index
    @severite_pages, @severites = paginate :severites, :per_page => 10
  end

  def show
    @severite = Severite.find(params[:id])
  end

  def new
    @severite = Severite.new
  end

  def create
    @severite = Severite.new(params[:severite])
    if @severite.save
      flash[:notice] = _("Severity was successfully created.")
      redirect_to severites_path
    else
      render :action => 'new'
    end
  end

  def edit
    @severite = Severite.find(params[:id])
  end

  def update
    @severite = Severite.find(params[:id])
    if @severite.update_attributes(params[:severite])
      flash[:notice] = _("Severity was successfully updated.")
      redirect_to severite_path(@severite)
    else
      render :action => 'edit'
    end
  end

  def destroy
    Severite.find(params[:id]).destroy
    redirect_to severites_path
  end
end
