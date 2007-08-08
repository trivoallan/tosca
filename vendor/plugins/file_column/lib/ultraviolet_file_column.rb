module FileColumn # :nodoc:
  
  FILE_MODE_ASSOCIATION_UV = { :rb => "ruby" }
  
  class BaseUploadedFile # :nodoc:

    def transform_with_uv
      if needs_transform?
        content = "" 
        File.open(absolute_path, "r+") { |f| content = f.read }
        
        file_extension = absolute_path.split('.').last
        if FileColumn::FILE_MODE_ASSOCIATION_UV.has_key?(file_extension)
          mode = FileColumn::FILE_MODE_ASSOCIATION_UV[file_extension.to_sym]
        else
          mode = file_extension
        end
        
        result = Uv.parse(content, "xhtml", mode, true, options[:uv][:theme])
        path = absolute_path << "." << options[:uv][:theme] << ".html"
        File.open(path, "w+") { |f| f.write(result) }
        GC.start
      end
    end
    
    def create_uv_version_if_needed
      path = absolute_path << "." << options[:uv][:theme] << ".html"
      unless File.exists?(path)
        transform_with_uv
      end
    end

    private
    
    def needs_transform?
      options.has_key?(:uv) and just_uploaded?
    end

  end

  module UltraVioletExtension

    def self.file_column(klass, attr, options) # :nodoc:
      require 'uv'
      options[:uv][:theme] = "espresso_libre" unless options[:uv].has_key? :theme 

      state_method = "#{attr}_state".to_sym
      after_assign_method = "#{attr}_uv_after_assign".to_sym
      
      klass.send(:define_method, after_assign_method) do
        if send(state_method).get_content_type =~ /^text\//
          self.send(state_method).transform_with_uv
        end
      end
      
      options[:after_upload] ||= []
      options[:after_upload] << after_assign_method
    end

  end
end
