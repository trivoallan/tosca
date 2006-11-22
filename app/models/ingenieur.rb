#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Ingenieur < ActiveRecord::Base
  belongs_to :identifiant, :dependent => :destroy
  has_and_belongs_to_many :competences
  has_and_belongs_to_many :contrats
  has_many :demandes

  def self.ingenieur?(identifiant)
    Ingenieur.find_by_identifiant_id(identifiant.id).nil?
  end
  
  def nom
    identifiant.nom
  end
end
