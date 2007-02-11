#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Socle < ActiveRecord::Base
  has_one :machine, :dependent => :destroy
  has_many :binaires
  has_many :paquets, :through => :binaires, :group => 'paquets.id' 

  has_and_belongs_to_many :clients

  def to_s
    nom
  end
end
