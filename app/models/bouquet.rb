#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Bouquet < ActiveRecord::Base
  has_many :classifications
end
