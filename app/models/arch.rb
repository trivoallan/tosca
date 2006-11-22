#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Arch < ActiveRecord::Base
  has_many :paquets
end
