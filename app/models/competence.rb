#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Competence < ActiveRecord::Base

  def to_s
    nom
  end
end
