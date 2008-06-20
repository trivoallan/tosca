class Ingenieur < ActiveRecord::Base
  acts_as_reportable

  belongs_to :user, :dependent => :destroy

  has_many :knowledges, :order => 'knowledges.level DESC'
  has_many :demandes
  has_many :phonecalls

  INCLUDE = [:user]

  def self.find_select_by_contract_id(contract_id)
    joins = 'INNER JOIN contracts_users cu ON cu.user_id=users.id'
    conditions = [ 'cu.contract_id = ?', contract_id ]
    options = {:find => {:conditions => conditions, :joins => joins}}
    result = []
    Ingenieur.send(:with_scope, options) do
      Ingenieur.find_select(User::SELECT_OPTIONS)
    end
  end

  # Don't forget to make an :include => [:user] if you
  # use this small wrapper.
  def name
    user.name
  end
end
