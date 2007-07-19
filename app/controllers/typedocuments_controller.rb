#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class TypedocumentsController < ApplicationController
  def index
    @typedocument_pages, @typedocuments = paginate :typedocuments, :per_page => 10
  end

  def show
    @typedocument = Typedocument.find(params[:id])
  end

  def new
    @typedocument = Typedocument.new
  end

  def create
    @typedocument = Typedocument.new(params[:typedocument])
    if @typedocument.save
      flash[:notice] = 'Typedocument was successfully created.'
      redirect_to typedocuments_path
    else
      render :action => 'new'
    end
  end

  def edit
    @typedocument = Typedocument.find(params[:id])
  end

  def update
    @typedocument = Typedocument.find(params[:id])
    if @typedocument.update_attributes(params[:typedocument])
      flash[:notice] = 'Typedocument was successfully updated.'
      redirect_to typedocument_path(@typedocument)
    else
      render :action => 'edit'
    end
  end

  def destroy
    Typedocument.find(params[:id]).destroy
    redirect_to typedocuments_path
  end

end
