class Release < ActiveRecord::Base
  include Comparable
  
  belongs_to :version
  belongs_to :contract

  has_one :changelog

  def full_name
    @full_name ||= "#{self.version.full_name} #{self.release}"
  end
  
  def full_software_name
    @full_software_name ||= "#{self.version.full_software_name} #{self.release}"
  end
  
  def logiciel
    version.logiciel
  end
  
  def <=>(other)
    return 1 if other.nil? or not other.is_a?(Release)
    self.name <=> other.name
  end

  # See ApplicationController#scope
  def self.set_scope(contract_ids)
    self.scoped_methods << { :find => { :conditions =>
        [ 'relases.contract_id IN (?)', contract_ids ]
      } } if contract_ids
  end
  
  private
  def release
    "r#{self.name}"
  end

end
