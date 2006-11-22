#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Support < ActiveRecord::Base
  def interval_in_seconds
    return (fermeture - ouverture) * 1.hour
  end
end

