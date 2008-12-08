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
class WelcomeController < ApplicationController
  # Includes somme helpers
  helper :issues, :account, :contributions, :softwares, :groupes, :documents, :clients

  # Default page, redirect if necessary
  def index
  end

  # Display all method that user can access
  def plan
    _plan
  end

  # About this software
  def about
  end

  # Used to select a theme, even without an account
  def theme
    case request.method
    when :get
      render :nothing unless request.xhr?
      render :layout => false
    when :post
      theme = params[:theme]
      session[:theme] = "themes/#{theme}.css" unless theme.blank?
      redirect_to welcome_path
    else
      render :nothing
    end
  end

  # nodoc
  def suggestions
    suggestion = params[:suggestion]
    if suggestion
      unless suggestion[:team].blank?
        Notifier::deliver_welcome_idea(suggestion[:team],
                                       :team, session[:user])
      end
      unless suggestion[:tosca].blank?
        Notifier::deliver_welcome_idea(suggestion[:tosca],
                                       :tosca, session[:user])
      end
      flash[:notice] = _("Thank your for taking time in order to help us to improve this product. Your comments has been sent successfully.")
      redirect_to_home
    end
  end
  
  #Action to clear the cache of Tosca 
  # !! ONLY FOR ADMINS !!
  def clear_cache
    if session[:user].role_id == 1
      #TODO : Find a better way, and call directly the rake task tmp:cache:clear
      FileUtils.rm_rf(Dir['tmp/cache/[^.]*'])
      flash[:notice] = _("Cache cleared !")
    end
    redirect_to_home
  end

protected

  # Returns an array of a pair : [ 'controller', *actions ]
  def _plan
    #Sorting routes by controller name
    routes = ActionController::Routing::Routes.routes.sort do |a, b|
      a.requirements[:controller] <=> b.requirements[:controller]
    end

    @routes = []
    last_controller = nil
    routes.each do |r|
      if last_controller != r.requirements[:controller]
        # sort actions list, in order to display'em nicely
        # uniq is there coz' we can have multiple paths with different verbs
        @routes.last.last.sort!.uniq! unless @routes.empty?
        @routes.push [ r.requirements[:controller], Array.new ]
      end
      @routes.last.last.push r.requirements[:action]
      last_controller = r.requirements[:controller]
    end
    # do not forget the last one
    @routes.last.last.sort!.uniq! unless @routes.empty?
  end

end
