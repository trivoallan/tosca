#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Beneficiaire < ActiveRecord::Base
  belongs_to :identifiant, :dependent => :destroy
  belongs_to :client, :counter_cache => true

  has_and_belongs_to_many :projets

  #TODO : revoir la hiérarchie avec un nested tree (!)
  belongs_to :beneficiaire
  has_many :demandes, :dependent => :destroy
  

  def nom
    return identifiant.nom if identifiant
  end


  def contrat_ids
    return client.contrats.collect{|c| c.id}.join(',')
  end

  alias_method :to_s, :nom
end
