#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class BienvenueController < ApplicationController
  # Includes somme helpers
  helper :demandes, :account, :contributions, :logiciels, :groupes, :documents, :clients

  before_filter :login_required, :except => [:index,:about]

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

  #nodoc
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

protected

  def _plan
    #Sorting routes by controller name
    routes = ActionController::Routing::Routes.routes.sort do |a,b|
      result = (a.requirements[:controller] <=> b.requirements[:controller])
    end

    @routes = []
    last_controller = nil
    #Get the routes only one time (we don't care if there is a post AND a get route for the same controller/action)
    routes.each do |r|
      if last_controller != r.requirements[:controller]
        @routes.last.last.sort!.uniq! unless @routes.size.zero?
        @routes.push [ r.requirements[:controller], Array.new ]
      else
        @routes.last.last.push r.requirements[:action]
      end
      last_controller = r.requirements[:controller]
    end
  end

end
