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
    render(:nothing => true)
  end

  # GET /subscriptions/1/edit
  def edit
    render(:nothing => true)
  end

  # POST /subscriptions
  def create
    render(:nothing => true)
  end

  # PUT /subscriptions/1
  def update
    render(:nothing => true)
  end

  # DELETE /subscriptions/1
  def destroy
    render(:nothing => true)
  end

end
