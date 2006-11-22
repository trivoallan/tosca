class Document < ActiveRecord::Base
  belongs_to :client
  belongs_to :typedocument
  belongs_to :identifiant
  file_column :fichier


  #versioning, qui s'occupe de la table documents_versions
  acts_as_versioned
  validates_length_of :titre, :within => 3..60

  def nomfichier
    return fichier[/[._ \-a-zA-Z0-9]*$/] if fichier
  end

  def to_param
    "#{id}-#{titre.gsub(/[^a-z1-9]+/i, '-')}"
  end

  def self.content_columns 
    @content_columns ||= columns.reject { |c| c.primary || 
        c.name =~ /(_id|_on|fichier)$/ || c.name == inheritance_column } 
  end

end
