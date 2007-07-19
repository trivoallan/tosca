#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class ChangelogsController < ApplicationController
  def index
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
      redirect_to changelogs_path
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
      redirect_to changelog_path(@changelog)
    else
      render :action => 'edit'
    end
  end

  def destroy
    Changelog.find(params[:id]).destroy
    redirect_to changelogs_path
  end
end

