class Archive < ActiveRecord::Base
  belongs_to :release
  
  validates_presence_of :name, :message => _('You must select a file to upload')

  file_column :name, :fix_file_extensions => nil

  def name
    read_attribute(:name)
  end
end