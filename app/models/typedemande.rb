class Typedemande < ActiveRecord::Base
  has_many :engagements
  has_many :demandes
end
