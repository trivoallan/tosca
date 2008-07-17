# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class <%= class_name %> < Tosca::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/<%= file_name %>"
  
  # define_routes do |map|
  #   map.connect 'admin/<%= file_name %>/:action', :controller => 'admin/<%= file_name %>'
  # end
  
  def activate
  end
  
  def deactivate
  end
  
end
