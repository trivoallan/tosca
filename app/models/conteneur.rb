#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Conteneur < ActiveRecord::Base
  has_many :paquets
end
