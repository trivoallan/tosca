#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Support < ActiveRecord::Base

  has_many :clients

  def interval_in_seconds
    return (fermeture - ouverture) * 1.hour
  end

  def to_s
    "Ouvert de #{ouverture}h à #{fermeture}h"
  end 

end

