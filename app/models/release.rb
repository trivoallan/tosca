class Release < ActiveRecord::Base
  belongs_to :version
  belongs_to :contract
  
  has_one :changelog
  
  def name
    "#{self.version.logiciel.name} v#{self.version.version} r#{self.release}"
  end
  
end
