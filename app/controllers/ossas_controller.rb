class OssasController < ApplicationController
  def index
    @ossa_pages, @ossas = paginate :ossas, :per_page => 10
  end

  def show
    @ossa = Ossa.find(params[:id])
  end

  def new
    @ossa = Ossa.new
  end

  def create
    @ossa = Ossa.new(params[:ossa])
    if @ossa.save
      flash[:notice] = _('Ossa was successfully created.')
      redirect_to ossas_path
    else
      render :action => 'new'
    end
  end

  def edit
    @ossa = Ossa.find(params[:id])
  end

  def update
    @ossa = Ossa.find(params[:id])
    if @ossa.update_attributes(params[:ossa])
      flash[:notice] = _('Ossa was successfully updated.')
      redirect_to ossas_path
    else
      render :action => 'edit'
    end
  end

  def destroy
    Ossa.find(params[:id]).destroy
    redirect_to ossas_path
  end
end
