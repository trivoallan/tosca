class ArchivesController < ApplicationController
  helper :releases, :archives

  def index
    @archive_pages, @archives = paginate :archives, :per_page => 10,
      :include => :release
  end

  def show
    @archive = Archive.find(params[:id])
  end

  def new
    @archive = Archive.new
    @archive.release_id = params[:release_id]
    _form
  end

  def create
    @archive = Archive.new(params[:archive])
    if @archive.save
      flash[:notice] = _('This archive has been successfully created.')
      redirect_to release_path(@archive.release)
    else
      _form
      render :action => 'new'
    end
  end

  def edit
    @archive = Archive.find(params[:id])
    _form
  end

  def update
    @archive = Archive.find(params[:id])
    if @archive.update_attributes(params[:archive])
      flash[:notice] = _('This archive has been successfully updated.')
      redirect_to archive_path(@archive)
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    Archive.find(params[:id]).destroy
    redirect_back
  end

  private
  def _form
    @releases = Release.all.collect { |r| [r.full_software_name, r.id ]}
  end
  
end
