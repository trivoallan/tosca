class Version < ActiveRecord::Base
  belongs_to :logiciel
  
  has_many :releases, :dependent => :destroy
  has_many :contributions

  validates_presence_of :logiciel, :name

  def full_name
    @full_name ||= "#{logiciel.name} v#{self.name}"
  end

end
