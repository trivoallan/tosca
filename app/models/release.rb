class Release < ActiveRecord::Base
  belongs_to :version
  belongs_to :contract
  belongs_to :logiciel
  
  has_one :changelog
  
  def name
    "#{self.version} r#{self.release}"
  end
  
  def self.set_scope(contract_ids)
    self.scoped_methods << { :find => { :conditions =>
          [ 'releases.contract_id IN (?)', contract_ids ]} }
  end
end
