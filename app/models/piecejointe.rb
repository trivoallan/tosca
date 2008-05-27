class Piecejointe < ActiveRecord::Base
  file_column :file, :fix_file_extensions => nil,
    :uv => {
      :theme => "active4d"
    },
    :magick => {
      :versions => {
        :fit_size => { :size => "800x600>" }
      }
    }

  has_one :commentaire

  validates_presence_of :file, :commentaire

  def name
    return file[/[._ \-a-zA-Z0-9]*$/]
  end

  # special scope : only used for file downloads
  # see FilesController
  def self.set_scope(client_id)
    joins = ''
    joins << 'LEFT OUTER JOIN commentaires ON commentaires.piecejointe_id = piecejointes.id '
    joins << 'LEFT OUTER JOIN demandes ON demandes.id = commentaires.demande_id '
    joins << 'LEFT OUTER JOIN beneficiaires ON beneficiaires.id = demandes.beneficiaire_id '
    self.scoped_methods << { :find => {
       :conditions => [ 'beneficiaires.client_id = ?', client_id ],
       :joins => joins }
    }
  end

end
