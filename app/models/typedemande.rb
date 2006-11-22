#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Typedemande < ActiveRecord::Base
  has_many :engagements
  has_many :demandes
end
