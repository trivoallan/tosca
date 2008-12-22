class SubscriptionsController < ApplicationController
  # GET /subscriptions
  def index
    @subscriptions = Subscription.find(:all)
  end

  # GET /subscriptions/1
  def show
    @subscription = Subscription.find(params[:id])
  end

  # GET /subscriptions/new
  def new
    @subscription = Subscription.new
    _form
  end

  # GET /subscriptions/1/edit
  def edit
    @subscription = Subscription.find(params[:id])
    _form
  end

  # POST /subscriptions
  def create
    @subscription = Subscription.new(params[:subscription])

    if @subscription.save
      flash[:notice] = _('The subscription was successfully created.')
      redirect_to(@subscription)
    else
      render :action => "new"
    end
  end

  # PUT /subscriptions/1
  def update
    @subscription = Subscription.find(params[:id])

    if @subscription.update_attributes(params[:subscription])
      flash[:notice] = _('The subscription was successfully updated.')
      redirect_to(@subscription)
    else
      render :action => "edit"
    end
  end

  # DELETE /subscriptions/1
  def destroy
    @subscription = Subscription.find(params[:id])
    @subscription.destroy

   redirect_to(subscriptions_url)
  end

  private
  def _form
    @users = User.all
  end
end
