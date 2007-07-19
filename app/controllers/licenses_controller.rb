#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class LicensesController < ApplicationController
  def index
    @license_pages, @licenses = paginate :licenses, :per_page => 10
  end

  def show
    @license = License.find(params[:id])
  end

  def new
    @license = License.new
  end

  def create
    @license = License.new(params[:license])
    if @license.save
      flash[:notice] = 'License was successfully created.'
      redirect_to licenses_path
    else
      render :action => 'new'
    end
  end

  def edit
    @license = License.find(params[:id])
  end

  def update
    @license = License.find(params[:id])
    if @license.update_attributes(params[:license])
      flash[:notice] = 'License was successfully updated.'
      redirect_to license_path(@license)
    else
      render :action => 'edit'
    end
  end

  def destroy
    License.find(params[:id]).destroy
    redirect_to licenses_path
  end
end
