class Archive < ActiveRecord::Base
  belongs_to :release
  
  validates_presence_of :file, :message => _('You must select a file to upload')

  file_column :file, :fix_file_extensions => nil, :size => true

  def name
    read_attribute(:file)
  end
end