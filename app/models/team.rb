class Team < ActiveRecord::Base
  
  has_and_belongs_to_many :users
  has_and_belongs_to_many :contrats
  belongs_to :contact, :class_name => "User"
  
  validates_uniqueness_of :name
  validates_presence_of :name
    
end