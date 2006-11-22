#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Fournisseur < ActiveRecord::Base
  has_many :paquets
end
