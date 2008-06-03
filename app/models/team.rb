class Team < ActiveRecord::Base
  
  has_and_belongs_to_many :contrats
  
  has_many :users
  
  belongs_to :contact, :class_name => 'User',
    :foreign_key => 'contact_id'
    
  validates_uniqueness_of :name
  validates_presence_of :name
    
end