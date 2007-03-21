#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Competence < ActiveRecord::Base
  has_and_belongs_to_many :ingenieurs

  def to_s
    nom
  end
end
