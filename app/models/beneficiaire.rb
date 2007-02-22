#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Beneficiaire < ActiveRecord::Base
  belongs_to :identifiant, :dependent => :destroy
  belongs_to :client, :counter_cache => true

  has_and_belongs_to_many :projets

  INCLUDE = [:identifiant]

  #TODO : revoir la hiérarchie avec un nested tree (!)
  belongs_to :beneficiaire
  has_many :demandes, :dependent => :destroy

  def nom
    (identifiant ? identifiant.nom : '')
  end

  def contrat_ids
    @cache ||=  Contrat.find(:all, :select => 'id', 
                             :conditions => ['client_id=?', 
                                             self.client_id]).collect{|c| c.id}
  end

  def scope_filter
    super scope_filter
  end

  alias_method :to_s, :nom
end
