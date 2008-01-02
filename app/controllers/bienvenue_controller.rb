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

  # Returns an array of a pair : [ 'controller', *actions ]
  def _plan
    #Sorting routes by controller name
    routes = ActionController::Routing::Routes.routes.sort do |a,b|
      result = (a.requirements[:controller] <=> b.requirements[:controller])
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
