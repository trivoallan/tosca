class Severite < ActiveRecord::Base
  has_many :demandes
  has_many :engagements

end
