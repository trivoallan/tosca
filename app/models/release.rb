class Release < ActiveRecord::Base
  include Comparable

  belongs_to :version
  belongs_to :contract

  has_one :changelog

  has_many :archives, :dependent => :destroy

  def full_name
    @full_name ||= "#{self.version.full_name} r#{self.name}"
  end

  def full_software_name
    @full_software_name ||= "#{self.version.full_software_name} r#{self.name}"
  end

  def logiciel
    version.logiciel
  end

  def <=>(other)
    return 1 if other.nil? or not other.is_a?(Release)
    res = self.version <=> other.version
    return res unless res == 0
    self.name <=> other.name
  end

  # See ApplicationController#scope
  def self.set_scope(contract_ids)
    self.scoped_methods << { :find => { :conditions =>
        [ 'releases.contract_id IN (?)', contract_ids ]
      } } if contract_ids
  end

end
