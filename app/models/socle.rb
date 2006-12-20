#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Socle < ActiveRecord::Base
  has_one :machine, :dependent => :destroy
  has_many :paquets
  belongs_to :client # TODO :
  # Mettre des filtres (before_create||before_update) pour maintenir
  # la consistance entre la réalité des paquets.socle et la vision client.socle

  def to_s
    nom
  end
end
