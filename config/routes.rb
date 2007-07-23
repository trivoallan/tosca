#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################

# A small overrides, in order to have shorter routes
module ActionController::Routing
  class RouteSet
    # this overloads allows to have REST routes for non-orm controllers
    class Mapper
      # Mapper for non-resource controller
      def without_orm(controller, actions, method = :get)
        actions.each { |action|
          self.send("#{action}_#{controller}", "#{controller};#{action}",
                    { :controller => controller, :action => action,
                      :conditions => { :method => method }})
        }
      end

      # Mapper for exporting with format, done in a special controller 'export'.
      def formatted_export(actions)
        actions.each { |action|
          self.send('named_route', "formatted_#{action}_export", "export/#{action}.:format",
                    { :controller => 'export', :action => action,
                      :conditions => { :method => :get }})
        }
      end
    end
  end
end

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

  map.without_orm('bienvenue', %w(admin plan selenium about deroulement
    natures statut suggestions engagements declaration severites statuts))
  map.without_orm('bienvenue', %w(suggestions), :post)
  map.without_orm('reporting', %w(comex configuration general comex_resultat))
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
    :collection => { :logout => :post, :login => :any,
      :auto_complete_for_identifiant_nom => :post,
      :auto_complete_for_identifiant_email => :post},
    :new => { :signup => :any, :multiple_signup => :any }
  map.resources :appels,  :collection => { :ajax_beneficiaires => :get }
  map.resources :arches
  map.resources :beneficiaires
  map.resources :binaires
  map.resources :changelogs
  map.resources :clients
  map.resources :competences
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
  map.resources :pictures
  map.resources :ingenieurs,  :collection => { :list => :get }
  map.resources :jourferies
  map.resources :logiciels
  map.resources :machines
  map.resources :pages
  map.resources :paquets
  map.resources :permissions
  map.resources :roles
  map.resources :socles
  map.resources :statuts
  map.resources :typecontributions
  map.resources :urllogiciels
  map.resources :urlreversements

  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action
  # map.connect '', :controller => "bienvenue"

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'

end
