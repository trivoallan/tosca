class Release < ActiveRecord::Base
  belongs_to :version
  belongs_to :contract

  has_one :changelog

  def full_name
    @full_name ||= "#{self.version.full_name} r#{self.name}"
  end
  
  def logiciel
    version.logiciel
  end

  # See ApplicationController#scope
  def self.set_scope(contract_ids)
    self.scoped_methods << { :find => { :conditions =>
        [ 'relases.contract_id IN (?)', contract_ids ]
      } } if contract_ids
  end

end
