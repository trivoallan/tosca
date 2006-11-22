#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Beneficiaire < ActiveRecord::Base
  belongs_to :identifiant, :dependent => :destroy
  belongs_to :client

  #TODO : revoir la hiérarchie avec un nested tree (!)
  belongs_to :beneficiaire
  has_many :demandes, :dependent => :destroy

  def nom
    return identifiant.nom if identifiant
  end


  def contrat_ids
    return client.contrats.collect{|c| c.id}.join(',')
  end

end
