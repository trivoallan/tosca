class Typedemande < ActiveRecord::Base
  has_many :commitments
  has_many :demandes
end
