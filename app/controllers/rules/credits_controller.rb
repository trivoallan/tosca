class Rules::CreditsController < ApplicationController

  def index
    @credits_pages, @credits = paginate :credits, :per_page => 10
  end

  def show
    @credit = Rules::Credit.find(params[:id])
  end

  def new
    @credit = Rules::Credit.new
  end

  def edit
    @credit = Rules::Credit.find(params[:id])
  end

  def create
    @credit = Rules::Credit.new(params[:credit])
    if @credit.save
      flash[:notice] = _("'%s' was successfully created.") % @credit.name
      redirect_to(@credit)
    else
      render :action => "new"
    end
  end

  def update
    @credit = Rules::Credit.find(params[:id])
    if @credit.update_attributes(params[:credit])
      flash[:notice] = _("'%s' was successfully updated.") % @credit.name
      redirect_to(@credit)
    else
      render :action => "edit"
    end
  end

  def destroy
    @credit = Rules::Credit.find(params[:id])
    @credit.destroy
    redirect_to(rules_credits_path)
  end

end
