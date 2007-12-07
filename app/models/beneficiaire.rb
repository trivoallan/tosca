
#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Beneficiaire < ActiveRecord::Base
  acts_as_reportable
  belongs_to :user, :dependent => :destroy
  belongs_to :client, :counter_cache => true

  has_many :phonecalls

  INCLUDE = [:user]

  #TODO : revoir la hiérarchie avec un nested tree (!)
  belongs_to :beneficiaire
  has_many :demandes, :dependent => :destroy

  validates_presence_of :client

  def name
    (user ? user.name : '')
  end

  def contrat_ids
    @cache ||=  Contrat.find(:all, :select => 'id',
      :conditions => ['client_id=?', self.client_id]).collect{|c| c.id}
  end

  alias_method :to_s, :name
end
