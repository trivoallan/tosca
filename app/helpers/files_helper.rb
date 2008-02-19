module FilesHelper

  def path_to_uv(object, method)
    App::FilesPath + url_for_uv_column(object, method)
  end

end
