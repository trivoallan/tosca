module FileColumn # :nodoc:
  
  class BaseUploadedFile # :nodoc:

    def transform_with_uv
      if needs_transform?
        content = "" 
        File.open(absolute_path, "r+") { |f| content = f.read }
        result = Uv.parse(content, "xhtml", "#{absolute_path.split('.').last}", true, options[:uv][:theme])
        path = absolute_path << "." << options[:uv][:theme] << ".html"
        File.open(path, "w+") { |f| f.write(result) }
        GC.start
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
