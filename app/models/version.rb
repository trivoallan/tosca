class Version < ActiveRecord::Base
  belongs_to :logiciel
  
  has_many :releases, :dependent => :destroy
  has_many :contributions

  validates_presence_of :logiciel, :version

  def name
    @name ||= "#{logiciel.name} v#{version}"
  end

  def self.set_scope(contract_ids)
    self.scoped_methods << { :find => { :conditions =>
      [ 'versions.contract_id IN (?)', contract_ids ]} }
  end

end
