=begin
  This file contains generic tasks for Tosca
=end

namespace :tosca do

  desc "Generate a default Database with default values."
  task :generate => [ 'db:create', 'db:migrate', 'db:fixtures:load']

  desc "Configure a new Tosca instance"
  task :install do
  end

  desc "Unpacks the specified gems and its dependencies into vendor/gems"
  task :unpack_gems => 'gems:base' do
    require 'rubygems'
    require 'rubygems/gem_runner'
    gems = []
    Rails.configuration.gems.each do |gem|
      gem.install unless gem.loaded?
      gems << gem
      gems << gem.dependencies
      # gem.dependencies.each {|g| puts g.name }
    end
    gems.flatten!
    # gems.uniq! does not work on a Rails::GemDependency Array.
    tmp, indexes = Hash.new, []
    gems.dup.each_with_index do |g,idx|
      # Hoe gem sucks :
      # it has particular rights which forbids 2 consecutive unpacking
      hash = (g.name == 'hoe' ? "#{g.name}" : "#{g.name} #{g.requirement.to_s}").to_sym
      indexes << idx if tmp.has_key?(hash)
      tmp[hash] = true
    end
    indexes.reverse!
    indexes.each{|i| gems.delete_at(i)}

    gems.sort!{|a,b| a.name <=> b.name}
    gems.each do |gem|
      next unless !gem.frozen? && (ENV['GEM'].blank? || ENV['GEM'] == gem.name)
      gem.unpack_to(File.join(RAILS_ROOT, 'vendor', 'gems')) unless gem.frozen?
    end
  end


  desc "Configure a new Tosca instance"
  task :install do
    require 'fileutils'
    root = RAILS_ROOT
    FileUtils.mkdir_p "#{root}/log"

    print "Use default access to mysql [Y/n] ?"
    if STDIN.gets.chomp! != 'n'
      FileUtils.cp "#{root}/config/database.yml.sample",
                   "#{root}/config/database.yml"
    end
    FileUtils.cp "#{root}/config/config.rb.sample", "#{root}/config/config.rb"
    # needed for dev mode, when stylesheets are not cached in single file.
    FileUtils.ln_s '../../public/images/' 'public/stylesheets/images'

    Rake::Task['l10n:mo'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
  end


  namespace :dist do
    desc "Generate small tarball for public distribution"
  	task :minimal do
      sh "git archive --format=tar --prefix=tosca/ HEAD > tosca.tar"
      print "update tosca code for working without gem & extensions"
      sh %q{sed -i -e "s/require 'desert'/#require 'desert'/" \
                 -e "s/config.gem/#config.gem/" config/environment.rb}
      sh %q{sed -i -e "s/gem 'gettext'/#gem 'gettext'/" \
                    vendor/plugins/gettext_localize/init.rb}
      sh %q{cd ..; tar -uf tosca/tosca.tar tosca/config/environment.rb \
                        tosca/vendor/plugins/gettext_localize/init.rb; cd -}
      sh %q{git checkout config/environment.rb \
                vendor/plugins/gettext_localize/init.rb}
      Rake::Task['rails:freeze:gems'].invoke
      sh "cd ..; tar -rf tosca/tosca.tar tosca/vendor/rails; cd -"
      Rake::Task['rails:unfreeze'].invoke
      sh "bzip2 -f tosca.tar"
    end
    desc "Generate small tarball for public distribution"
  	task :all do
      sh "git archive --format=tar --prefix=tosca/ HEAD > tosca.tar"
      Rake::Task['rails:freeze:gems'].invoke
      sh "cd ..; tar -rf tosca/tosca.tar tosca/vendor/rails; cd -"
      Rake::Task['rails:unfreeze'].invoke
	  sh "cd vendor/extensions; git archive --format=tar --prefix=tosca/vendor/extensions/ HEAD > ../../extensions.tar; cd -"
	  sh "tar -A extensions.tar -f tosca.tar; rm -f extensions.tar"
	  Rake::Task['gems:unpack'].invoke
      sh "cd ..; tar -rf tosca/tosca.tar tosca/vendor/gems; cd -; rm -Rf vendor/gems"
      sh "bzip2 -f tosca.tar"
    end
  end

end
