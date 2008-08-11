module FilesHelper
  
  # Take the size in bytes and prints the size in megabytes
  def size_in_megabytes(size)
    "#{sprintf('%.2f ', size/1024.0)}" << _("MB")
  end

end
