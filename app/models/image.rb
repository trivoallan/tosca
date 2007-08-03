#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Image < ActiveRecord::Base
  file_column :image, :magick => { 
    :versions => { "thumb" => "150x50", "medium" => "640x480" }
  }, :root_path => File.join(RAILS_ROOT, "public")

end
