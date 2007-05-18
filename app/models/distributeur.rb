#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Distributeur < ActiveRecord::Base
  has_many :paquets
end
