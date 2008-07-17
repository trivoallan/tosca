class Release < ActiveRecord::Base
  belongs_to :version
  belongs_to :contract
  belongs_to :logiciel
  
  has_one :changelog
  
  def name
    "#{self.logiciel.name} v#{self.version.version} r#{self.release}"
  end
  
end
