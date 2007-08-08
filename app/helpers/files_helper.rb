module FilesHelper
 
  def path_to_uv(object, method)
    Metadata::PATH_TO_FILES + url_for_uv_column(object, method)
  end

end