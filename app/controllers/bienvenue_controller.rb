#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class BienvenueController < ApplicationController

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }
  
  # Includes somme helpers
  helper :demandes, :account

  skip_before_filter :login_required
  before_filter :login_required, :except => [:index,:about]


  # Default page, redirect if necessary
  def index
    _request_list
    @typedocuments = Typedocument.find(:all)
    # this line will be deleted when index is ready
    #render :action => 'list'
    @request_stats = _request_stats
  end


  # Welcome page
  # DEPRECATED : use index
  def list
    _request_list
  end

  # New welcome page, current development
  def test
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
    conditions = Demande::EN_COURS
    @demandes = Demande.find(:all, 
       :include => [:statut, :typedemande, :severite], 
       :limit => 5, :order => 'updated_on DESC ',
       :conditions => conditions)
  end 

  # Some stats for current user
  # return request_stats hash for engineer or beneficiaire
  # TODO : add a graph ?
  # TODO : think querues as Ingenieur.method and Beneficiaire.method ?
  def _request_stats
    request_stats = {}
    include = [:statut]
    if session[:user].ingenieur
      id = session[:user].ingenieur.id 
      role = 'ingenieur'
    else 
      id = session[:user].beneficiaire.id 
      role = 'beneficiaire'
    end
    conditions = [" demandes.#{role}_id = ? AND #{Demande::EN_COURS} ", id ]
    request_stats[:en_cours] = Demande.find(:all, 
      :conditions => conditions, :include => include).size
    conditions = [" demandes.#{role}_id = ? AND #{Demande::TERMINEES} ", id ]
    request_stats[:terminees] = Demande.find(:all, 
      :conditions => conditions, :include => include).size
    request_stats
  end

end

