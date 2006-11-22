class Demandechange < ActiveRecord::Base
  belongs_to :demande
  belongs_to :statut
  # migration 006 :
  belongs_to :identifiant
end
