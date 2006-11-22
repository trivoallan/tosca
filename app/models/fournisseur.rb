class Fournisseur < ActiveRecord::Base
  has_many :paquets
end
