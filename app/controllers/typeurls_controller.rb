#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class TypeurlsController < ApplicationController
  def index
    @typeurl_pages, @typeurls = paginate :typeurls, :per_page => 50
  end

  def show
    @typeurl = Typeurl.find(params[:id])
  end

  def new
    @typeurl = Typeurl.new
  end

  def create
    @typeurl = Typeurl.new(params[:typeurl])
    if @typeurl.save
      flash[:notice] = _("A url type was successfully created.")
      redirect_to typeurls_path
    else
      render :action => 'new'
    end
  end

  def edit
    @typeurl = Typeurl.find(params[:id])
  end

  def update
    @typeurl = Typeurl.find(params[:id])
    if @typeurl.update_attributes(params[:typeurl])
      flash[:notice] = _("A url type was successfully updated.")
      redirect_to typeurl_path(@typeurl)
    else
      render :action => 'edit'
    end
  end

  def destroy
    Typeurl.find(params[:id]).destroy
    redirect_to typeurls_path
  end
end
