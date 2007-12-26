#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Groupe < ActiveRecord::Base
  has_many :logiciels

  def self.set_scope(contrat_ids)
    self.scoped_methods << { :find => { :conditions =>
        [ 'paquets.contrat_id IN (?)', contrat_id ],
        :joins => 'INNER JOIN logiciels ON logiciels.groupe_id=groupes.id ' +
        'INNER JOIN paquets ON paquets.logiciel_id=logiciels.id'

      } }
  end

end
