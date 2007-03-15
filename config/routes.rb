#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  map.connect '', :controller => "bienvenue"

  # routing files to prevent download from public access
  options = { :controller => 'files', :action => 'download', :filename => /\w+(.\w+)*/ }
  map.files 'piecejointe/file/:id/:filename', options.update(:file_type => 'piecejointe')
  map.files 'contribution/patch/:id/:filename', options.update(:file_type => 'contribution')
  map.files 'document/fichier/:id/:filename', options.update(:file_type => 'document')
  map.files 'binaire/archive/:id/:filename', options.update(:file_type => 'binaire')

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
