class Version < ActiveRecord::Base
  has_one :logiciel, :through => :releases

  has_many :releases, :dependent => :destroy
  has_many :contributions

  validates_presence_of :logiciel, :version

  def name
    @name ||= "#{logiciel.name}-#{version}"
  end

  def self.set_scope(contract_ids)
    self.scoped_methods << { :find => { :conditions =>
      [ 'versions.contract_id IN (?)', contract_ids ]} }
  end

end
