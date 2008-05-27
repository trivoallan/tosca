class Image < ActiveRecord::Base
  belongs_to :logiciel
  has_one :client
  validates_presence_of :image, :message => _('You must select a file to upload')

  # TODO : rename this column into 'file', with the appropriate migration
  # /!\ do not forget to move Directory during this migration /!\
  file_column :image, :fix_file_extensions => nil, :magick => {
    :versions => {
      :small => { :size => "75x25" },
      :thumb => { :size => "150x50" },
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

  def name
    return _("Logo '%s'") % logiciel.name if logiciel
    return _("Logo '%s'") % client.name if client
    description
  end
end
