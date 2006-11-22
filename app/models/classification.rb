#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################

class Classification < ActiveRecord::Base
  belongs_to :logiciel
  belongs_to :groupe
  belongs_to :bouquet
  belongs_to :client
end
