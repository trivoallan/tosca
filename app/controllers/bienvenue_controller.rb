#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class BienvenueController < ApplicationController

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }
  
  # Includes somme helpers
  helper :demandes, :account, :contributions, :logiciels, :groupes, :documents, :clients

  skip_before_filter :login_required
  before_filter :login_required, :except => [:index,:about]

  # Default page, redirect if necessary
  def index
    _request_list
  end



  # Display all method that user can access
  def plan
    _plan
  end

  # Functionnal testing
  def selenium
    _plan
    render :layout => false
  end

  # About this software
  def about
  end

  #nodoc
  def suggestions
    suggestion = params[:suggestion]
    if suggestion
      unless suggestion[:team].blank?
        Notifier::deliver_bienvenue_suggestion(suggestion[:team],
                                               :team, session[:user])
      end
      unless suggestion[:tosca].blank?
        Notifier::deliver_bienvenue_suggestion(suggestion[:tosca],
                                               :tosca, session[:user])
      end
      flash[:notice] = _("Merci d'avoir pris le temps de nous aider à " <<
            "améliorer cet outil. Vos suggestions ont bien été envoyées")
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

  # Pick some demands
  # Used to be shown in the welcome page
  def _request_list
    @demandes = Demande.find(:all, :include => [:severite], 
       :limit => 5, :order => 'updated_on DESC ',
       :conditions => Demande::EN_COURS)
  end 


end

