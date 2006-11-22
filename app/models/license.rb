#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class License < ActiveRecord::Base
  has_many :logiciels
end
