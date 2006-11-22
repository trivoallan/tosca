class Socle < ActiveRecord::Base
  has_one :machine
  has_many :paquets
  has_many :demandes
end
