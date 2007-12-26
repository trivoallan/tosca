#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Arch < ActiveRecord::Base
  has_many :binaires

  validates_presence_of :name
end
