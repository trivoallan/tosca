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

  def contract_ids
    @cache ||=  user.contract_ids
  end

  def contracts
    self.user.contracts
  end

end
