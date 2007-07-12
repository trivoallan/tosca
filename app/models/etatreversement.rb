#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Etatreversement < ActiveRecord::Base
  acts_as_reportable
  has_many :contributions
end
