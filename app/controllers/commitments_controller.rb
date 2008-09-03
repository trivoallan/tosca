class CommitmentsController < ApplicationController
  def index
    @commitment_pages, @commitments = paginate :commitments,
    :per_page => 20, :order => "typedemande_id, severite_id",
    :include => [:typedemande,:severite]
  end

  def show
    @commitment = Commitment.find(params[:id])
  end

  def new
    @commitment = Commitment.new
    _form
  end

  def create
    @commitment = Commitment.new(params[:commitment])
    if @commitment.save
      flash[:notice] = 'Commitment was successfully created.'
      redirect_to commitments_path
    else
      _form
      render :action => 'new'
    end
  end

  def edit
    @commitment = Commitment.find(params[:id])
    _form
  end

  def update
    @commitment = Commitment.find(params[:id])
    if @commitment.update_attributes(params[:commitment])
      flash[:notice] = 'Commitment was successfully updated.'
      redirect_to commitments_path
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    Commitment.find(params[:id]).destroy
    redirect_to commitments_path
  end

  private
  def _form
    @typedemandes = Typedemande.find_select
    @severites = Severite.find_select
  end
end
