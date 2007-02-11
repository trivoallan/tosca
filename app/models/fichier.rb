#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Fichier < ActiveRecord::Base
  belongs_to :paquet, :counter_cache => true
end
