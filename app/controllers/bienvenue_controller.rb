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

  # Return all methods sorted by class name
  def _plan
    classes = Hash.new;
    require 'find'
    Find.find(File.join(RAILS_ROOT, 'app/controllers'))  { |name|
        require_dependency(name) if /_controller\.rb$/ =~ name
    }
    # définition de @classes[] : listes des controllers de l'application
    ObjectSpace.subclasses_of(::ActionController::Base).each do |obj|
      classes["#{obj.controller_name}"] = obj
    end
    @classes = classes.sort {|a,b| a[0]<=>b[0]}
  end

end
