begin
  require 'rcov/rcovtask' 
rescue
  print "You have install rcov"
  print "sudo gem install spicycode-rcov --source=http://gems.github.com/"
end
 
desc 'Measures test coverage using rcov'
namespace :rcov do
  desc 'Output unit test coverage of plugin.'
  Rcov::RcovTask.new(:unit) do |rcov|
    rcov.pattern    = 'test/unit/**/*_test.rb'
    rcov.output_dir = 'rcov'
    rcov.verbose    = true
  end
 
  desc 'Output functional test coverage of plugin.'
  Rcov::RcovTask.new(:functional) do |rcov|
    rcov.pattern    = 'test/functional/**/*_test.rb'
    rcov.output_dir = 'rcov'
    rcov.verbose    = true
  end
end
