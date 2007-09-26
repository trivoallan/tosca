#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################

# special overrides, since routes can be reloaded
# in rails, even in production.
require 'routes_overrides'

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
  # nice to see welcome in url, and it's needed by official portal
  map.bienvenue '/bienvenue', sweet_home

  map.without_orm('bienvenue', %w(admin plan selenium about deroulement
    natures statut suggestions declaration))
  map.without_orm('bienvenue', %w(suggestions), :post)
  map.without_orm('reporting', %w(comex comex_resultat configuration flux general))
  map.without_orm('acces', %w(refuse))
  map.without_orm('export', %w(demandes_ods appels_ods identifiants_ods
    contributions_ods comex_ods) )

  map.formatted_export(%w(requests contributions identifiants appels comex))

  # routing files to prevent download from public access
  # TODO : convertir en route nommée
  options = { :controller => 'files', :action => 'download', :filename => /\w+(.\w+)*/ }
  %w(piecejointe contribution document binaire).each { |file|
    map.files "#{file}/file/:id/:filename", options.update(:file_type => file)
  }

  # RESTful routes with ORM
  # Sample call :
  #   link_to _('..'), edit_account_path(:id => a.id)
  #   link_to _('..'), accounts_path()
  # !!! CONVENTION !!!
  # - It MUST be in alphabetical order -
  # !!! CONVENTION !!!
  map.resources :accounts,
    :controller => "account",
    :member => { :devenir => :post },
    :collection => { :logout => :any, :login => :any },
    :new => { :signup => :any, :multiple_signup => :any }
  map.resources :appels,  :collection => { :ajax_beneficiaires => :get }
  map.resources :arches
  map.resources :binaires
  map.resources :changelogs
  map.resources :clients
  map.resources :commentaires, :member => {
     :changer_etat => :post,
     :comment => :post }
  map.resources :competences
  map.resources :conteneurs
  map.resources :contrats
  map.resources :contributions,
    :collection => { :admin => :any, :select => :get },
    :member => { :list => :get }
  map.resources :demandes,
    :collection => { :ajax_display_packages => :post },
    :member => { :comment=> :any,
      :associer_contribution => :post,
      :delete_contribution => :post,
      :print => :get,
      :ajax_description => :get,
      :ajax_comments => :get,
      :ajax_history => :get,
      :ajax_piecejointes => :get,
      :ajax_appels => :get,
      :ajax_cns => :get }
  map.resources :dependances
  map.resources :distributeurs
  map.resources :documents,
    :collection => { :select => :get },
    :member => { :list => :get, :destroy => :delete }
  map.resources :engagements
  map.resources :etatreversements
  map.resources :fichiers
  map.resources :fournisseurs
  map.resources :groupes
  map.resources :ingenieurs
  map.resources :beneficiaires
  # We cannot have 'image' for singular, coz'
  # image_path is used in ActionView::Helpers of Rails
  map.resources :images, :singular => 'img'
  map.resources :jourferies, :singular => 'jourferie'
  map.resources :licenses
  map.resources :logiciels
  map.resources :machines
  map.resources :mainteneurs
  # 'news'.singularize == 'news' So problems comes
  map.resources :news, :singular => 'new',
    :collection => { :newsletter => :get, :newsletter_result => :post }
  map.resources :pages
  map.resources :paquets, :collection =>
    { :auto_complete_for_paquet_nom => :any}
  map.resources :permissions
  map.resources :piecejointes, :member => { :uv => :get }
  map.resources :reporting, :collection => { :flux => :get }
  map.resources :roles
  map.resources :socles
  map.resources :statuts, :member => { :help => :get }
  map.resources :severites
  map.resources :supports
  map.resources :typecontributions
  map.resources :typedemandes
  map.resources :typedocuments
  map.resources :typeurls
  map.resources :urls

  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action
  # map.connect '', :controller => "bienvenue"

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # kept in order to keep integration with original portal, in php.
  map.connect 'account/login', :controller => 'account', :action => 'login'

  # Install the default route as the lowest priority.
  # map.connect ':controller/:action/:id'
end
