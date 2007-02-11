#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Groupe < ActiveRecord::Base
  has_many :classifications
end
