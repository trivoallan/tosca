class Version < ActiveRecord::Base
  belongs_to :logiciel

  has_many :releases, :dependent => :destroy
  has_many :contributions

  has_and_belongs_to_many :contracts, :uniq => true

  validates_presence_of :logiciel, :name

  def self.set_scope(contract_ids)
    self.scoped_methods << { :find => { :conditions =>
        [ 'contracts_versions.contract_id IN (?)', contract_ids ], :joins =>
        "INNER JOIN contracts_versions ON contracts_versions.version_id = versions.id"} }
  end

  def full_name
    "v#{self.name}"
  end

  def full_software_name
    @full_software_name ||= "#{self.logiciel.name} #{self.full_name}"
  end

  def name
    return @name if @name
    @name = read_attribute(:name)
    @name = "#{@name}.*" if self.generic?
    @name
  end

  include Comparable
  def <=>(other)
    return 1 if other.nil? or not other.is_a?(Version)
    res = self.logiciel <=> other.logiciel
    return res unless res == 0

    #ri Comparable for more info
    res = 1 if self.generic? and not other.generic?
    res = -1 if not self.generic? and other.generic?

    #If both are generic or both are not
    res = self.name <=> other.name if res == 0
    res
  end

end
