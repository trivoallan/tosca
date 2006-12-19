#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Interaction < ActiveRecord::Base
  belongs_to :logiciel, :counter_cache => true
  belongs_to :ingenieur, :counter_cache => true
  has_one :reversement
end
