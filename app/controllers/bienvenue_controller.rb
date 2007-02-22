#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class BienvenueController < ApplicationController

  helper :demandes, :account

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  #    @user = @session[:user] # cf identifiants
  def list
    conditions = [ "statut_id NOT IN (?,?)", 7, 8 ]
#     if @ingenieur
#       @demandes = Demande.find_all_by_ingenieur_id(@ingenieur.id,
#                                                    :include => 'statut',
#                                                    :limit => 5,
#                                                    :conditions => conditions,
#                                                    :order => "updated_on DESC")
 #      @clients = @ingenieur.contrats.collect{|c| c.client.nom}
#     elsif @beneficiaire
#       # Ce code a été copié depuis le controller de demandes, dans scope_beneficiaire
#       # C'est mal, il faudra trouver une solution
#       liste = @beneficiaire.client.beneficiaires.collect{|b| b.id}.join(',')
#       conditions = [ "demandes.beneficiaire_id IN (#{liste})" ]
#       Demande.with_scope({ :find => { :conditions => conditions } }) do
    @demandes = Demande.find(:all, :include => [:statut,:typedemande,:severite], 
                             :limit => 5,  :order => "updated_on DESC ")
#       end
#       @client = @beneficiaire.client.nom
#     else    
#       flash[:warn] = "Vous n'êtes pas identifié comme appartenant à un groupe.\
#                         Veuillez nous contacter pour nous avertir de cet incident."
#       @demandes = [] # renvoi un tableau vide
#     end   

  end

  def plan
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

