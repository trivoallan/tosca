class Rules::ComponentsController < ApplicationController

  def index
    @component_pages, @components = paginate Rules::Component, :per_page => 10
  end

  def show
    @component = Rules::Component.find(params[:id])
  end

  def new
    @component = Rules::Component.new
  end

  def edit
    @component = Rules::Component.find(params[:id])
  end

  def create
    @component = Rules::Component.new(params[:component])
    if @component.save
      flash[:notice] = _("'%s' was successfully created.") % @component.name
      redirect_to(@component)
    else
      render :action => "new"
    end
  end

  def update
    @component = Rules::Component.find(params[:id])
    if @component.update_attributes(params[:component])
      flash[:notice] = _("'%s' was successfully updated.") % @component.name
      redirect_to(@component)
    else
      render :action => "edit"
    end
  end

  def destroy
    @component = Rules::Component.find(params[:id])
    @component.destroy
    redirect_to(rules_components_path)
  end

end
