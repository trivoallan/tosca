class TagsController < ApplicationController
  def index
    options = { :per_page => 50, :order => 'tags.name' }
    @tag_pages, @tags = paginate :tags, options
  end

  def show
    @tag = Tag.find(params[:id])
  end

  def new
    @tag = Tag.new
    _form
  end

  def create
    @tag = Tag.new(params[:tag])
    @tag.user_id = session[:user].id
    if @tag.save
      flash[:notice] = _('Skill was successfully created.')
      redirect_to tags_path
    else
      render :action => 'new'
    end
  end

  def edit
    @tag = Tag.find(params[:id])
    _form
  end

  def update
    @tag = Tag.find(params[:id])
    if @tag.update_attributes(params[:tag])
      flash[:notice] = _('Skill was successfully updated.')
      redirect_to tag_path(@tag)
    else
      render :action => 'edit'
    end
  end

  def destroy
    Tag.find(params[:id]).destroy
    redirect_to tags_path
  end

private
  def _form
    @competences = Competence.find_select
    @contracts = Contract.find_select(Contract::OPTIONS)
  end
end

