require 'rake/testtask'

namespace :db do
  namespace :migrate do
    desc "Run all Tosca extension migrations"
    task :extensions => :environment do
      require 'tosca/extension_migrator'
      Tosca::ExtensionMigrator.migrate_extensions
    end
  end
  namespace :remigrate do
    desc "Migrate down and back up all Tosca extension migrations"
    task :extensions => :environment do
      require 'highline/import'
      if agree("This task will destroy any data stored by extensions in the database. Are you sure you want to \ncontinue? [yn] ")
        require 'tosca/extension_migrator'
        Tosca::Extension.descendants.map(&:migrator).each {|m| m.migrate(0) }
        Rake::Task['db:migrate:extensions'].invoke
      end
    end
  end
end

namespace :test do
  desc "Runs tests on all available Tosca extensions, pass EXT=extension_name to test a single extension"
  task :extensions => "db:test:prepare" do
    extension_roots = Tosca::Extension.descendants.map(&:root)
    if ENV["EXT"]
      extension_roots = extension_roots.select {|x| /\/(\d+_)?#{ENV["EXT"]}$/ === x }
      if extension_roots.empty?
        puts "Sorry, that extension is not installed."
      end
    end
    extension_roots.each do |directory|
      if File.directory?(File.join(directory, 'test'))
        chdir directory do
          # Not sure this one works as intended.
          # TODO : test it so we can remove this comment
		  system "rake test RAILS_ENV_FILE=#{RAILS_ROOT}/config/environment"
        end
      end
    end
  end
end

namespace :tosca do
  namespace :extensions do
    desc "Runs update asset task for all extensions"
    task :update_all => :environment do
      extension_names = Tosca::ExtensionLoader.instance.extensions.map { |f| f.to_s.underscore.sub(/_extension$/, '') }
      extension_update_tasks = extension_names.map { |n| "tosca:extensions:#{n}:update" }.select { |t| Rake::Task.task_defined?(t) }
      extension_update_tasks.each {|t| Rake::Task[t].invoke }
    end
  end
end

namespace :tosca do
  namespace :extensions do
    desc "Runs update asset task for all extensions"
    task :update_all => :environment do
      extension_names = Tosca::ExtensionLoader.instance.extensions.map { |f| f.to_s.underscore.sub(/_extension$/, '') }
      extension_update_tasks = extension_names.map { |n| "tosca:extensions:#{n}:update" }.select { |t| Rake::Task.task_defined?(t) }
      extension_update_tasks.each {|t| Rake::Task[t].invoke }
    end
  end
end

namespace :tosca do
  namespace :extensions do
    desc "Runs update asset task for all extensions"
    task :update_all => :environment do
      extension_names = Tosca::ExtensionLoader.instance.extensions.map { |f| f.to_s.underscore.sub(/_extension$/, '') }
      extension_update_tasks = extension_names.map { |n| "tosca:extensions:#{n}:update" }.select { |t| Rake::Task.task_defined?(t) }
      extension_update_tasks.each {|t| Rake::Task[t].invoke }
    end
  end
end

# Load any custom rakefiles from extensions
Dir[RAILS_ROOT + '/vendor/extensions/*/lib/tasks/*.rake'].sort.each { |ext| load ext }
