class ExtensionGenerator < Rails::Generator::NamedBase
  attr_reader :extension_path, :extension_file_name

  def initialize(runtime_args, runtime_options = {})
    super
    @extension_file_name = "#{file_name}_extension"
    @extension_path = "vendor/extensions/#{file_name}"
  end

  def manifest
    record do |m|
      m.directory "#{extension_path}/app/controllers"
      m.directory "#{extension_path}/app/helpers"
      m.directory "#{extension_path}/app/models"
      m.directory "#{extension_path}/app/views"
      m.directory "#{extension_path}/db/migrate"
      m.directory "#{extension_path}/lib/tasks"

      m.template 'README',              "#{extension_path}/README"
      m.template 'extension.rb',        "#{extension_path}/#{extension_file_name}.rb"
      m.template 'tasks.rake',          "#{extension_path}/lib/tasks/#{extension_file_name}_tasks.rake"

      m.directory "#{extension_path}/test/fixtures"
      m.directory "#{extension_path}/test/functional"
      m.directory "#{extension_path}/test/unit"

      m.template 'Rakefile',            "#{extension_path}/Rakefile"
      m.template 'test_helper.rb',      "#{extension_path}/test/test_helper.rb"
      m.template 'functional_test.rb',  "#{extension_path}/test/functional/#{extension_file_name}_test.rb"
    end
  end

  def class_name
    super.to_name.gsub(' ', '') + 'Extension'
  end

  def extension_name
    class_name.to_name('Extension')
  end

end
