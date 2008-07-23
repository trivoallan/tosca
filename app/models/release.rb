class Release < ActiveRecord::Base
  belongs_to :version
  belongs_to :contract
  belongs_to :logiciel

  has_one :changelog

  def full_name
    @full_name ||= "#{self.version.full_name} r#{self.name}"
  end

  # See ApplicationController#scope
  def self.set_scope(contract_ids)
    self.scoped_methods << { :find => { :conditions =>
        [ 'relases.contract_id IN (?)', contract_ids ]
      } } if contract_ids
  end

end
