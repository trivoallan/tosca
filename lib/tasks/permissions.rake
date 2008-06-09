namespace :tosca do 
  namespace :permissions do
     
    desc "Reset the permissions"
    task :reload do
      ENV["VERSION"] = "3"
      ENV["MODEL"] = "Permission"
      Rake::Task['db:migrate:down'].invoke
      Rake::Task['db:migrate:up'].invoke
      Rake::Task['db:fixtures:dump'].invoke
    end

  end
end
