class Version < ActiveRecord::Base
  belongs_to :logiciel
  has_many :releases, :dependent => :destroy
  has_and_belongs_to_many :contributions
    
  validates_presence_of :logiciel, :version
  
  
  # (cf Conventions de développement : wiki)
  ORDER = 'versions.logiciel_id, versions.version DESC'
  OPTIONS = { :order => ORDER }

  def to_s
    [ logiciel.name, version ].compact.join('-')
  end
  
end
