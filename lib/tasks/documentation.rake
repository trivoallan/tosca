

namespace :doc do
  WWW_ROOT='/var/www/rdoc/'

  desc "Generate all documentation for Tosca"
  Rake::RDocTask.new("tosca") { |rdoc|
    rdoc.rdoc_dir = "#{WWW_ROOT}tosca"
    rdoc.title    = "Tosca Documentation"
    rdoc.template = "lib/template"
    rdoc.options << '--line-numbers' << '--inline-source'
    rdoc.options << '-c utf8 --quiet'
    rdoc.rdoc_files.include('doc/README')
    rdoc.rdoc_files.include('app/**/*.rb')
    rdoc.rdoc_files.include('lib/**/*.rb')
  }


  namespace :tplugins do		    
    plugins = FileList['vendor/plugins/**'].collect { |plugin| File.basename(plugin) }
    task :all => plugins.collect { |plugin| "doc:tplugins:#{plugin}" }


    # Define doc tasks for each plugin
    plugins.each do |plugin|
      task(plugin => :environment) do
        plugin_base   = "vendor/plugins/#{plugin}"
        options       = []
        files         = Rake::FileList.new
        options << "-o #{WWW_ROOT}plugins/#{plugin}"
        options << "--title '#{plugin.titlecase} Plugin Documentation'"
        options << '--line-numbers' << '--inline-source'
	options << '-c utf8 --quiet'
        options << '-T lib/template'

        files.include("#{plugin_base}/lib/**/*.rb")
        if File.exists?("#{plugin_base}/README")
          files.include("#{plugin_base}/README")    
          options << "--main '#{plugin_base}/README'"
        end
        files.include("#{plugin_base}/CHANGELOG") if File.exists?("#{plugin_base}/CHANGELOG")

        options << files.to_s

        sh %(rdoc #{options * ' '})
      end
    end
  end

end