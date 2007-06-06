#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Severite < ActiveRecord::Base
  has_many :demandes
  has_many :engagements

end
