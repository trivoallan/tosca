#
# Copyright (c) 2006-2008 Linagora
#
# This file is part of Tosca
#
# Tosca is free software, you can redistribute it and/or modify
# it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
# Tosca is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

class SoftwaresController < ApplicationController
  helper :filters, :versions, :issues, :competences, :contributions, :licenses

  # Not used for the moment
  # auto_complete_for :software, :name

  # ajaxified list
  def index
    scope = nil
    @title = _('List of software')
    if @recipient && params['active'] != '0'
      scope = :supported
      @title = _('List of your supported software')
    end

    options = { :per_page => 10, :order => 'softwares.name', :include => [:groupe] }
    conditions = []

    if params.has_key? :filters
      session[:software_filters] = Filters::Softwares.new(params[:filters])
    end
    conditions = nil
    software_filters = session[:software_filters]
    if software_filters
      # we do not want an include since it's only for filtering.
      unless software_filters['contract_id'].blank?
        options[:joins] =
          'INNER JOIN versions ON versions.software_id=softwares.id ' +
          'INNER JOIN contracts_versions cv ON cv.version_id=versions.id'
      end

      # Specification of a filter f :
      #   [ field, database field, operation ]
      # All the fields must be coherent with lib/filters.rb related Struct.
      conditions = Filters.build_conditions(software_filters, [
        [:software, 'softwares.name', :like ],
        [:description, 'softwares.description', :like ],
        [:groupe_id, 'softwares.groupe_id', :equal ],
        [:contract_id, ' cv.contract_id', :in ]
      ])
      @filters = software_filters
    end
    flash[:conditions] = options[:conditions] = conditions

    # optional scope, for customers
    begin
      Software.set_scope(@recipient.contract_ids) if scope
      @software_pages, @softwares = paginate :softwares, options
    ensure
      Software.remove_scope if scope
    end

    # panel on the left side. cookies is here for a correct 'back' button
    if request.xhr?
      render :partial => 'software_list', :layout => false
    else
      _panel
      @partial_for_summary = 'software_info'
    end
  end

  def show
    @software = Software.find(params[:id])
    if @recipient
      @issues = @recipient.issues.find(:all, :conditions =>
                                              ['issues.software_id=?', params[:id]])
    else
      @issues = Issue.find(:all, :conditions =>
                               ['issues.software_id=?',params[:id]])
    end
  end

  def card
    @software = Software.find(params[:id])
  end

  def new
    @software = Software.new
    _form
  end

  def create
    @software = Software.new(params[:software])
    if @software.save and add_logo
      flash[:notice] = _('The software %s has been created succesfully.') % @software.name
      redirect_to software_path(@software)
    else
      add_image_errors
      _form and render :action => 'new'
    end
  end

  def edit
    @software = Software.find(params[:id])
    _form
  end

  def update
    @software = Software.find(params[:id])
    if @software.update_attributes(params[:software]) and add_logo
      flash[:notice] = _('The software %s has been updated successfully.') % @software.name
      redirect_to software_path(@software)
    else
      add_image_errors
      _form and render :action => 'edit'
    end
  end

  def destroy
    @software = Software.find(params[:id])
    @software.destroy
    flash[:notice] = _('The software %s has been successfully deleted.') % @software.name
    redirect_to softwares_path
  end

  def ajax_update_tags
    @software = Software.find(:first, :conditions => { :name => params["software"]["name"] } )
    @competences_check = Competence.find(params["software"]["competence_ids"]) unless params["software"]["competence_ids"] == [""]
    render :partial => 'softwares/tags', :layout => false
  end

private
  def _form
    @competences = Competence.find_select
    @groupes = Groupe.find_select
    @licenses = License.find_select
  end

  def _panel
    @contracts = Contract.find_select(Contract::OPTIONS) if @ingenieur
    @technologies = Competence.find_select
    @groupes = Groupe.find_select

    stats = Struct.new(:technologies, :versions, :software)
    @count = stats.new(Competence.count, Version.count, Software.count)
  end

  def add_logo
    image = params[:image]
    unless image.nil? || image[:image].blank?
      image[:description] = @software.name
      @software.image = Image.new(image)
      return @software.image.save
    end
    return true
  end

  # because :save resets @software.errors
  def add_image_errors
    unless @software.image.nil?
      @software.image.errors.each do |attr, msg|
        @software.errors.add :image, msg
      end
    end
  end


end
