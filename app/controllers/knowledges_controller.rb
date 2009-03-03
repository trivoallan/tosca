#
# Copyright (c) 2006-2009 Linagora
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
class KnowledgesController < ApplicationController

  def index
    options = { :per_page => 25, :order => 'knowledges.engineer_id',
      :include => [:engineer, :skill, :software], :page => params[:page] }

    if params.has_key? :filters
      session[:knowledges_filters] =
        Filters::Knowledges.new(params[:filters])
    end
    conditions = nil
    knowledges_filters = session[:knowledges_filters]
    if knowledges_filters
      # Specification of a filter f :
      #   [ field, database field, operation ]
      # All the fields must be coherent with lib/filters.rb related Struct.
      conditions = Filters.build_conditions(knowledges_filters, [
        [:software_id, 'knowledges.software_id', :equal ],
        [:skill_id, 'knowledges.skill_id', :equal ],
        [:engineer_id, 'knowledges.engineer_id', :equal ]
      ])
      @filters = knowledges_filters
    end
    flash[:conditions] = options[:conditions] = conditions

    @knowledges  = Knowledge.paginate options
    if request.xhr?
      render :layout => false
    else
      _panel
      @partial_panel = 'index_panel'
    end

  end

  def show
    @knowledge = Knowledge.find(params[:id])
  end

  def new
    @knowledge = Knowledge.new
    _form
  end

  def edit
    @knowledge = Knowledge.find(params[:id])
    _form
  end

  def create
    @knowledge = Knowledge.new(params[:knowledge])
    @knowledge.engineer_id = @session_user.id

    if @knowledge.save
      flash[:notice] = _('Your knowledge was successfully created.')
      redirect_to(account_path(@knowledge.engineer))
    else
      _form and render :action => "new"
    end
  end

  def update
    @knowledge = Knowledge.find(params[:id])
    if @knowledge.update_attributes(params[:knowledge])
      flash[:notice] = _('Your knowledge was successfully updated.')
      redirect_to(account_path(@knowledge.engineer))
    else
      _form and render :action => "edit"
    end
  end

  def destroy
    @knowledge = Knowledge.find(params[:id])
    @knowledge.destroy

    redirect_to(knowledges_url)
  end

  private
  def _form
    @skills = Skill.find_select
    @software = Software.find_select
  end

  def _panel
    @software = Software.find_select
    @skills = Skill.find_select
    @experts = User.find_select(User::EXPERT_OPTIONS)
  end

end
