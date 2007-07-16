#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class TypeurlsController < ApplicationController
  def index
    @typeurl_pages, @typeurls = paginate :typeurls, :per_page => 50
    render :action => 'list'
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
      flash[:notice] = 'Typeurl was successfully created.'
      redirect_to :action => 'list'
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
      flash[:notice] = 'Typeurl was successfully updated.'
      redirect_to :action => 'show', :id => @typeurl
    else
      render :action => 'edit'
    end
  end

  def destroy
    Typeurl.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
