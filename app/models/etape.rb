#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Etape < ActiveRecord::Base
  def to_s
    nom
  end
end
