class MoveSoftwareIdInPictureToPictureIdInSoftware < ActiveRecord::Migration
  class Picture < ActiveRecord::Base
    belongs_to :software
  end

  class Software < ActiveRecord::Base
    has_one :picture
  end

  def self.up
    add_column :softwares, :picture_id, :integer

    Picture.all.each do |p|
      p.software.update_attribute(:picture_id, p.id) if p.software_id
    end

    remove_column :pictures, :software_id
  end

  def self.down
    add_column :pictures, :software_id, :integer

    Software.all.each do |s|
      s.picture.update_attribute(:software_id, s.id) if s.picture_id
    end

    remove_column :softwares, :picture_id
  end
end
