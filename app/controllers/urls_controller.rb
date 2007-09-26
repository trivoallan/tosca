#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class UrlsController < ApplicationController
  helper :logiciels

  @@resource_type_list = [[ 'Logiciel', 'Logiciel'], [ 'Contribution', 'Contribution']]

  def index
    @url_pages, @urls = paginate :urls,
     :per_page => 10 ,
     :order => 'urls.id'
  end

  def show
    @myurl = Url.find(params[:id])
  end

  def new
    @myurl = Url.new
    _form
  end

  def create
    if  (params[:urls] and params[:urls][:value])
      @myurl = Url.new( :value => params[:urls][:value] )
    else
      @myurl = Url.new()
    end
    record_new_values
    if @myurl.save
      flash[:notice] = _('The url of "%s" has been created successfully.') %
        @myurl.value
      redirect_to urls_path
    else
      _form
      render :action => 'new'
    end
  end

  def edit
    @myurl = Url.find(params[:id])
    _form
  end

  def update
    @myurl = Url.find(params[:id])
    @myurl.value = params[:urls][:value] if (params[:urls] and params[:urls][:value])
    record_new_values
    if @myurl.save
        flash[:notice] = _("The Url has bean updated successfully.")
        redirect_to logiciel_path(@myurl.resource) if @myurl.resource_type == 'Logiciel'
        redirect_to contribution_path(@myurl.resource) if @myurl.resource_type == 'Contribution'
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    Url.find(params[:id]).destroy
    redirect_to urls_path
  end

private
  def _form
    @typeurls = Typeurl.find_select
    @logiciels = Logiciel.find_select
    @contributions = Contribution.find_select
  end

  def record_new_values
    if params[:urls][:resource_type] == "Logiciel"
      resource = Logiciel.find(params[:urls][:logiciel_id].to_i)
      typeurl = Typeurl.find(params[:urls][:typeurl_id].to_i)
    end
    if params[:urls][:resource_type] == "Contribution"
      resource = Contribution.find(params[:urls][:contribution_id].to_i)
      typeurl = nil
    end
    @myurl.resource = resource
    @myurl.typeurl = typeurl
  end

end
