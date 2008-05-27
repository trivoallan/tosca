class StatutsController < ApplicationController
  def index
    @statut_pages, @statuts = paginate :statuts, :per_page => 10, 
      :order => 'id'
  end

  def help
    @statut = Statut.find(params[:id])
    render :action => 'show', :layout => false
  end

  def show
    @statut = Statut.find(params[:id])
  end

  def new
    @statut = Statut.new
  end

  def create
    @statut = Statut.new(params[:statut])
    if @statut.save
      flash[:notice] = _('Status was successfully created.')
      redirect_to statuts_path
    else
      render :action => 'new'
    end
  end

  def edit
    @statut = Statut.find(params[:id])
  end

  def update
    @statut = Statut.find(params[:id])
    if @statut.update_attributes(params[:statut])
      flash[:notice] = _('Statut was successfully updated.')
      redirect_to statut_path(@statut)
    else
      render :action => 'edit'
    end
  end

  def destroy
    Statut.find(params[:id]).destroy
    redirect_to statuts_path
  end
end
