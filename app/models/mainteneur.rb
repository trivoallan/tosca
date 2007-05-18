#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Mainteneur < ActiveRecord::Base
  has_many :paquets
end
