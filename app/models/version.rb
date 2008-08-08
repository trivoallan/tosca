class Version < ActiveRecord::Base
  include Comparable
  
  belongs_to :logiciel
  
  has_many :releases, :dependent => :destroy
  has_many :contributions
  
  has_and_belongs_to_many :contracts

  validates_presence_of :logiciel, :name

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
  
  def <=>(other)
    return 1 if other.nil? or not other.is_a?(Version)
    
    #ri Comparable for more info
    if self.generic? and not other.generic?
      return 1
    elsif not self.generic? and other.generic?
      return -1
    end
    
    #If both are generic or both are not
    self.name <=> other.name
  end
  
end
