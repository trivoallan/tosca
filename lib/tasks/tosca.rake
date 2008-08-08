=begin
  This file contains generic tasks for Tosca
=end

namespace :tosca do

  desc "Generate a default Database with default values."
  task :generate => [ 'db:create', 'db:migrate', 'db:fixtures:load']

  desc "Configure a new Tosca instance"
  task :install do
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
    # TODO : Transform lib/config.rb into a YAML file,
    # so we can ask,parse & change it properly
    FileUtils.cp "#{root}/lib/config.rb.sample", "#{root}/lib/config.rb"

    Rake::Task['l10n:mo'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
  end


  desc "Generate tarballs for public distribution"
  task :dist do
    sh "git archive --format=tar --prefix=tosca/ HEAD > tosca.tar"
    sh %q{sed -i -e "s/require 'desert'/#require 'desert'/"
                 -e "s/gem 'gettext'/#gem 'gettext'/"
                 -e "s/config.gem/#config.gem/"
                    tosca.tar}
    Rake::Task['rails:freeze:gems'].invoke
    sh "cd ..; tar -rf tosca/tosca.tar tosca/vendor/rails; cd -"
    Rake::Task['rails:unfreeze'].invoke
    sh "bzip2 -f tosca.tar"
  end

end
