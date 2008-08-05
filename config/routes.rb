
# special overrides, since routes can be reloaded
# in rails, even in production.
require_dependency 'routes_overrides'

ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation:
  #   first created -> highest priority.

  # RESTful routes without ORM
  # it generates helper likes admin_welcome_url and admin_welcome_path
  # all those helpers only have GET method.
  # See overrides.rb for without_orm source code
  sweet_home = { :controller => 'welcome', :action => 'index',
                 :conditions => { :method => :get } }
  map.welcome '/', sweet_home

  map.without_orm('welcome', %w(admin plan about deroulement
    index natures statut suggestions declaration))
  map.without_orm('welcome', %w(suggestions), :post)
  map.without_orm('reporting', %w(comex comex_resultat configuration flux general digest digest_resultat))
  map.without_orm('access', %w(denied))
  map.without_orm('alerts', %w(on_submit index))
  map.without_orm('alerts', %w(ajax_on_submit), :post)

  # routing files to prevent download from public access
  # TODO : convertir en route nommée
  options = { :controller => 'files', :action => 'download', :filename => /\w+(.\w+)*/ }
  %w(file patch fichier archive).each { |file|
    map.files(":file_type/#{file}/:id/:filename", options)
  }

  # Autoloading Extensions Routes
  extension_path = "#{RAILS_ROOT}/vendor/extensions"
  Dir.foreach( extension_path ) { |ext|
    next if ext == '.'
    route_path = File.join extension_path, ext, 'config', 'routes.rb'
    map.routes_from_plugin(ext.to_sym) if File.exists? route_path
  } if File.exists? extension_path

  # RESTful routes with ORM
  # Sample call :
  #   link_to _('..'), edit_account_path(:id => a.id)
  #   link_to _('..'), accounts_path()
  # !!! CONVENTION !!!
  # - It MUST be in alphabetical order -
  # !!! CONVENTION !!!
  map.resources :accounts,
    :controller => "account",
    :member => { :become => :post, :ajax_contracts => :post },
    :collection => { :logout => :any, :login => :any, :lemon => :any },
    :new => { :signup => :any, # TODO : reactive it :multiple_signup => :any,
      :ajax_place => :post, :ajax_contracts => :post }
  map.resources :arches
  map.resources :changelogs
  map.resources :clients, :collection => { :stats => :get }
  map.resources :commentaires, :member => {
     :change_state => :post,
     :comment => :post }
  map.resources :competences
  map.resources :contracts,
    :collection => {
      :ajax_choose => :post, :actives => :get, :ajax_add_software => :post, :add_software => :post },
      :member => { :supported_software => :get }
  map.resources :contributions,
    :collection => { :admin => :any, :select => :get, :experts => :get },
    :member => { :list => :get }
  map.resources :demandes,
    :collection => { :pending => :get,
      :ajax_renew => :post, # in pending view
      :ajax_display_commitment => :post, # in new/edit form
      :ajax_display_version => :post, # in new/edit form
      :ajax_display_contract => :post }, # in new/edit form
    :member => { :print => :get, # All members are in show view
      :link_contribution => :post,
      :unlink_contribution => :post,
      :ajax_description => :get,
      :ajax_comments => :get,
      :ajax_history => :get,
      :ajax_attachments => :get,
      :ajax_appels => :get,
      :ajax_cns => :get }
  map.resources :distributeurs
  map.resources :documents,
    :collection => { :select => :get },
    :member => { :list => :get, :destroy => :delete }
  map.resources :commitments
  map.resources :etatreversements
  map.resources :fichiers
  map.resources :fournisseurs
  map.resources :groupes
  # We cannot have 'image' for singular, coz'
  # image_path is used in ActionView::Helpers of Rails
  map.resources :images, :singular => 'img'
  map.resources :knowledges
  map.resources :licenses
  map.resources :logiciels,
    :collection => {:ajax_update_tags => :get}
  map.resources :machines
  map.resources :mainteneurs
  # 'news'.singularize == 'news' So problems comes
  map.resources :news, :singular => 'new',
    :collection => { :newsletter => :get, :newsletter_result => :post }
  map.resources :ossas
  map.resources :pages
  map.resources :permissions
  map.resources :phonecalls,  :collection => { :ajax_recipients => :get }
  map.resources :attachments
  map.resources :releases
  map.resources :reporting, :collection => { :flux => :get }
  map.resources :roles

  # Resources for rules/* controllers
    map.resources :components, :controller => "rules/components",
      :path_prefix => "/rules", :name_prefix => 'rules_'
    map.resources :credits, :controller => "rules/credits",
      :path_prefix => "/rules", :name_prefix => 'rules_'

  map.resources :socles
  map.resources :statuts, :member => { :help => :get }
  map.resources :severites
  map.resources :supports
  map.resources :tags
  map.resources :teams, :collection => { :auto_complete_for_contract_name => :post }
  map.resources :time_tickets
  map.resources :typecontributions
  map.resources :typedemandes
  map.resources :typedocuments
  map.resources :typeurls
  map.resources :urllogiciels
  map.resources :urlreversements
  map.resources :versions

  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action
  # map.connect '', :controller => "welcome"

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # kept in order to keep integration with original portal, in php.
  map.connect 'account/login', :controller => 'account', :action => 'login'

  # Install the default route as the lowest priority.
  # map.connect ':controller/:action/:id'
end
