class WorkflowsController < ApplicationController
  # GET /workflows
  def index
    render :nothing => true
  end

  # GET /workflows/1
  def show
    render :nothing => true
  end

  # GET /workflows/new
  def new
    @workflow = Workflow.new
    _form
  end

  # GET /workflows/1/edit
  def edit
    @workflow = Workflow.find(params[:id])
    _form
  end

  # POST /workflows
  def create
    @workflow = Workflow.new(params[:workflow])
    @workflow.allowed_status_ids.delete_if{|s| s == 0}
    if @workflow.save
      flash[:notice] = 'Workflow was successfully created.'
      redirect_to(@workflow.issuetype)
    else
      _form and render :action => "new"
    end
  end

  # PUT /workflows/1
  def update
    @workflow = Workflow.find(params[:id])
    if @workflow.update_attributes(params[:workflow])
      flash[:notice] = 'Workflow was successfully updated.'
      redirect_to(@workflow.issuetype)
    else
      _form and render :action => "edit"
    end
  end

  # DELETE /workflows/1
  def destroy
    @workflow = Workflow.find(params[:id])
    @workflow.destroy
    redirect_to(@workflow.issuetype)
  end

  private
  def _form
    @workflow.issuetype_id ||= params[:issuetype_id]
    @workflow.allowed_status_ids ||= []
    @statuses = Statut.find_select(:order => 'statuts.id')
  end
end
