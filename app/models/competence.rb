#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Competence < ActiveRecord::Base
  has_many :knowledges
  has_many :ingenieurs, :through => :knowledges
end
