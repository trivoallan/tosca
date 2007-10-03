#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Image < ActiveRecord::Base
  file_column :image, :magick => {
    :versions => {
      :thumb => {:size => "150x50"},
      :medium => { :size => "640x480" },
      :inactive_thumb => { :size => "150x50",
        :transformation => Proc.new { |image|
          image.view(0, 0, image.columns, image.rows) do |view|
            center = image.rows/2
            view[[center-1, center, center+1]][] = 'black'
          end
          image
        }
      }
    }
  }, :root_path => File.join(RAILS_ROOT, "public")
end
