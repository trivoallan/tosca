#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class ImagesController < ApplicationController
  def index
    @image_pages, @images = paginate :images, :per_page => 10
  end

  def show
    @image = Image.find(params[:id])
  end

  def new
    @image = Image.new
  end

  def create
    @image = Image.new(params[:image])
    if @image.save
      flash[:notice] = 'Image was successfully created.'
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def edit
    @image = Image.find(params[:id])
  end

  def update
    @image = Image.find(params[:id])
    if @image.update_attributes(params[:image])
      flash[:notice] = 'Image was successfully updated.'
      redirect_to :action => 'show', :id => @image
    else
      render :action => 'edit'
    end
  end

  def destroy
    Image.find(params[:id]).destroy
    redirect_to :action => 'index'
  end
end
