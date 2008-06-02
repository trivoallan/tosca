### /lib/tasks/gettext.rake
#
# If you have inherited model classes, the gettext library cannot determine them because declaration line doesn't include ActiveRecord.
# You'll need to explicitly add them like SomeModel_1 ...



namespace :l10n do
  desc "Update pot/po files."
  task :po do
    require 'gettext/utils'
    GetText.update_pofiles("tosca", Dir.glob("{app,lib,bin}/**/*.{rb,erb,rjs,builder}"), "tosca 0.7.5")
  end

  desc "Create mo-files"
  task :mo do
    require 'gettext/utils'
    GetText.create_mofiles(true, "po", "locale")
  end

  desc "Translate all the stuff"
  task :all => [:po, :mo]
end
