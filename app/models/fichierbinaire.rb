#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Fichierbinaire < ActiveRecord::Base
  belongs_to :binaire, :counter_cache => true

  def name
    chemin
  end
end
