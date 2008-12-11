class HyperlinksController < ApplicationController
  # GET /hyperlinks
  def index
    @hyperlinks = Hyperlink.find(:all)
  end

  # GET /hyperlinks/1
  def show
    @hyperlink = Hyperlink.find(params[:id])
  end

  # GET /hyperlinks/new
  def new
    @hyperlink = Hyperlink.new
    @hyperlink.model_type = params[:model_type]
    @hyperlink.model_id = params[:model_id]
  end

  # GET /hyperlinks/1/edit
  def edit
    @hyperlink = Hyperlink.find(params[:id])
  end

  # POST /hyperlinks
  def create
    @hyperlink = Hyperlink.new(params[:hyperlink])
    if @hyperlink.save
      flash[:notice] = _('The url was successfully created.')
      redirect_to_controller
    else
      render :action => "new"
    end
  end

  # PUT /hyperlinks/1
  def update
    @hyperlink = Hyperlink.find(params[:id])

    if @hyperlink.update_attributes(params[:hyperlink])
      flash[:notice] = _('The url was successfully updated.')
      redirect_to_controller
    else
      render :action => "edit"
    end

  end

  # DELETE /hyperlinks/1
  def destroy
    @hyperlink = Hyperlink.find(params[:id])
    @hyperlink.destroy
    flash[:notice] = _('The url was successfully destroyed.')
    redirect_to_controller
  end

  private
  def redirect_to_controller
    redirect_to :controller => @hyperlink.model_type.pluralize,
        :action => :show, :id => @hyperlink.model_id
  end
end
