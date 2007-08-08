#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Image < ActiveRecord::Base
  file_column :image, :magick => { 
    :versions => { 
      :thumb => {:size => "150x50"}, 
      :medium => { :size => "640x480" }
    }
  }, :root_path => File.join(RAILS_ROOT, "public")
end
