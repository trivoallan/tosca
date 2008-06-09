class Team < ActiveRecord::Base
  
  belongs_to :contact, :class_name => 'User',
    :foreign_key => 'contact_id'
    
  has_many :users
  
  has_and_belongs_to_many :contrats
    
  validates_uniqueness_of :name
  validates_presence_of :name, :contact
  
  #Nice URL
  def to_param
    "#{id}-#{name.gsub(/[^a-z1-9]+/i, '-')}"
  end
    
end