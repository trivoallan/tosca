=begin
  This file contains generic tasks for Tosca
=end

namespace :tosca do
  
  desc "Generate a default Database with default values."
  task :generate => [ 'db:create', 'db:migrate', 'db:fixutres:load']
  
end