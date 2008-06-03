class Beneficiaire < ActiveRecord::Base
  acts_as_reportable
  belongs_to :user
  belongs_to :client, :counter_cache => true
  has_many :phonecalls

  INCLUDE = [:user]

  #TODO : revoir la hiérarchie avec un nested tree (!)
  belongs_to :beneficiaire
  has_many :demandes, :dependent => :destroy

  validates_presence_of :client

  def name
    (user ? user.name : '-')
  end

  def contrat_ids
    @cache ||=  user.contrat_ids
  end

  def contrats
    self.user.contrats
  end

end
