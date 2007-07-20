#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require 'overrides'
ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation:
  #   first created -> highest priority.

  # RESTful routes without ORM
  # it generates helper likes admin_bienvenue_url and admin_bienvenue_path
  # all those helpers only have GET method.
  # See overrides.rb for without_orm source code
  sweet_home = { :controller => 'bienvenue', :action => 'index',
                 :conditions => { :method => :get } }
  map.bienvenue '/', sweet_home

  map.without_orm('bienvenue',
    %w(admin plan selenium about deroulement natures statut suggestions engagements declaration severites statuts))
  map.without_orm('bienvenue', %w(suggestions), :post)
  map.without_orm('reporting', %w(comex configuration general comex_resultat))
  map.without_orm('export', %w(contributions demandes appels identifiants))
  map.without_orm('acces', %w(refuse))
  map.without_orm('export', %w(demandes_ods appels_ods identifiants_ods contributions_ods comex_ods) )

  # routing files to prevent download from public access
  # TODO : convertir en route nommée
  options = { :controller => 'files', :action => 'download', :filename => /\w+(.\w+)*/ }
  map.files 'piecejointe/file/:id/:filename', options.update(:file_type => 'piecejointe')
  map.files 'contribution/patch/:id/:filename', options.update(:file_type => 'contribution')
  map.files 'document/fichier/:id/:filename', options.update(:file_type => 'document')
  map.files 'binaire/archive/:id/:filename', options.update(:file_type => 'binaire')



  # RESTful routes with ORM
  # Sample call :
  #   link_to _('..'), edit_account_path(:id => a.id)
  #   link_to _('..'), accounts_path()
  map.resources :accounts,
  :controller => "account",
  :member => { :devenir => :post },
  :collection => { :logout => :post, :login => :any,
    :auto_complete_for_identifiant_nom => :post,
    :auto_complete_for_identifiant_email => :post},
  :new => { :signup => :any, :multiple_signup => :any }
  map.resources :appels,  :collection => { :ajax_beneficiaires => :get }
  map.resources :arches
  map.resources :beneficiaires
  map.resources :binaires
  map.resources :clients
  map.resources :competences
#  map.resources :dependances, :collection => { :select => :get }
  map.resources :contrats
  map.resources :contributions,
  :collection => { :admin => :any, :select => :get },
  :member => { :list => :get }
  map.resources :demandes,
  :collection => { :auto_complete_for_logiciel_nom => :post,
    :ajax_display_packages => :post },
  :member => { :comment=> :any,
    :associer_contribution => :get,
    :delete_contribution => :get,
    :update_contribution => :get,
    :changer_ingenieur => :get,
    :pretty_print => :get }
  map.resources :documents,
  :collection => { :select => :get },
  :member => { :list => :get, :destroy => :delete }
  map.resources :groupes
  map.resources :ingenieurs,  :collection => { :list => :get }
  map.resources :logiciels
  map.resources :pages
  map.resources :machines
  map.resources :changelogs
  map.resources :typecontributions,  :collection => { :destroy => :get }
  map.resources :paquets
  map.resources :permissions
  map.resources :roles
  map.resources :socles
  map.resources :statuts
  map.resources :jourferies
  map.resources :urllogiciels
  map.resources :urlreversements

  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action
  # map.connect '', :controller => "bienvenue"

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # routing files to prevent download from public access
  #options = { :controller => 'files', :action => 'download', :filename => /\w+(.\w+)*/ }
  #map.files 'piecejointe/file/:id/:filename', options.update(:file_type => 'piecejointe')
  #map.files 'contribution/patch/:id/:filename', options.update(:file_type => 'contribution')
  #map.files 'document/fichier/:id/:filename', options.update(:file_type => 'document')
  #map.files 'binaire/archive/:id/:filename', options.update(:file_type => 'binaire')

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  # map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'

end
