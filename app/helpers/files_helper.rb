module FilesHelper
 
  def path_to_uv(object, method)
    Metadata::PATH_TO_FILES + relative_url_uv(object, method)
  end

end