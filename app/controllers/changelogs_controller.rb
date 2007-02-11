#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class ChangelogsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @changelog_pages, @changelogs = paginate :changelogs, :per_page => 10
  end

  def show
    @changelog = Changelog.find(params[:id])
  end

  def new
    @changelog = Changelog.new
  end

  def create
    @changelog = Changelog.new(params[:changelog])
    if @changelog.save
      flash[:notice] = 'Changelog was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @changelog = Changelog.find(params[:id])
  end

  def update
    @changelog = Changelog.find(params[:id])
    if @changelog.update_attributes(params[:changelog])
      flash[:notice] = 'Changelog was successfully updated.'
      redirect_to :action => 'show', :id => @changelog
    else
      render :action => 'edit'
    end
  end

  def destroy
    Changelog.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
