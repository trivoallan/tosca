#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Demandechange < ActiveRecord::Base
  belongs_to :demande
  belongs_to :statut
  # migration 006 :
  belongs_to :identifiant
end
