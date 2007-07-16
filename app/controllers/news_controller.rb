class NewsController < ApplicationController
  def index
    @new_pages, @news = paginate :new, :per_page => 15
  end

  def show
    @new = New.find(params[:id])
  end

  def new
    @new = New.new
    @new.ingenieur = @ingenieur
    _form
  end

  def create
    @new = New.new(params[:new])
    if @new.save
      flash[:notice] = 'New was successfully created.'
      redirect_to :action => 'index'
    else
      _form and render :action => 'new'
    end
  end

  def edit
    @new = New.find(params[:id])
    _form
  end

  def update
    @new = New.find(params[:id])
    if @new.update_attributes(params[:new])
      flash[:notice] = 'New was successfully updated.'
      redirect_to :action => 'show', :id => @new
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    New.find(params[:id]).destroy
    redirect_to :action => 'index'
  end

  private
  def _form
    @ingenieurs = Ingenieur.find_select(Identifiant::SELECT_OPTIONS)
    @clients = Client.find_select
    @logiciels = Logiciel.find_select
  end
end
