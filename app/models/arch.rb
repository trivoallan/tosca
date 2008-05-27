class Arch < ActiveRecord::Base
  has_many :binaires, :include => :paquet

  validates_presence_of :name
end
