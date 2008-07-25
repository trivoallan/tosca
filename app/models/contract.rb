class Contract < ActiveRecord::Base
  acts_as_reportable

  belongs_to :client
  belongs_to :rule, :polymorphic => true
  belongs_to :creator, :class_name => 'User'

  has_many :releases, :dependent => :destroy
  has_many :demandes
  has_many :appels
  has_many :tags

  has_and_belongs_to_many :engagements, :order =>
    'typedemande_id, severite_id', :include => [:severite,:typedemande]
  has_and_belongs_to_many :users, :order => 'users.name'
  has_and_belongs_to_many :engineer_users, :class_name => 'User',
    :conditions => 'users.client = 0',
    :order => 'users.name ASC'
  has_and_belongs_to_many :recipient_users, :class_name => 'User',
    :conditions => 'users.client = 1', :include => :beneficiaire,
    :order => 'users.name ASC'
  has_and_belongs_to_many :teams, :order => 'teams.name'
  has_and_belongs_to_many :versions

  validates_presence_of :client, :rule, :creator
  validates_numericality_of :heure_ouverture, :heure_fermeture,
    :only_integer => true
  validates_inclusion_of :heure_ouverture, :heure_fermeture, :in => 0..24

  validate :must_open_before_close

  def must_open_before_close
    errors.add_to_base("The schedules of this contract are invalid.") unless heure_ouverture < heure_fermeture
  end

  Rules = [ 'Rules::Credit', 'Rules::Component' ]

  def self.set_scope(contract_ids)
    self.scoped_methods << { :find => { :conditions =>
        [ 'contracts.id IN (?)', contract_ids ] } }
  end

  def engineers
    engineers = self.engineer_users
    engineers.concat(self.teams.collect { |t| t.users }.flatten).uniq!
    engineers
  end

  def credit?
    rule_type == Rules.first
  end

  def interval_in_seconds
    return (heure_fermeture - heure_ouverture) * 1.hour
  end

  def interval
    heure_fermeture - heure_ouverture
  end

  # We have open clients which can declare
  # requests on everything. It's with the "socle" field.
  def logiciels
    if rule_type == 'Rules::Component' and rule.max == -1
      return Logiciel.find(:all, :order => 'logiciels.name ASC')
    end
    self._logiciels
  end

  # TODO : I am sure it could be better. Rework model ???
  def find_recipients_select
    options = { :conditions => 'users.inactive = 0' }
    self.recipient_users.find(:all, options).collect{|u|
      [  u.name, u.beneficiaire.id ] if u.beneficiaire }
  end

  def ouverture_formatted
    display_time read_attribute(:ouverture)
  end

  def cloture_formatted
    display_time read_attribute(:cloture)
  end

  def find_engagement(request)
    options = { :conditions =>
      [ 'engagements.typedemande_id = ? AND severite_id = ?',
        request.typedemande_id, request.severite_id ] }
    self.engagements.find(:first, options)
  end

  def demandes
    conditions = [ 'demandes.contract_id = ?', id]
    Demande.find(:all, :conditions => conditions)
  end

  def typedemandes
    joins = 'INNER JOIN engagements ON engagements.typedemande_id = typedemandes.id '
    joins << 'INNER JOIN contracts_engagements ON engagements.id = contracts_engagements.engagement_id'
    conditions = [ 'contracts_engagements.contract_id = ? ', id ]
    Typedemande.find(:all,
                     :select => "DISTINCT typedemandes.*",
                     :conditions => conditions,
                     :joins => joins)
  end

  INCLUDE = [:client]
  ORDER = 'clients.name ASC'
  OPTIONS = { :include => INCLUDE, :order => ORDER, :conditions =>
    "clients.inactive = 0" }

  def name
    specialisation = read_attribute :name
    res = "#{client.name} - #{rule.name}"
    res << " - #{specialisation}" unless specialisation.blank?
    res
  end

  # used internally by wrapper :
  # /!\ DO NOT USE DIRECTLY /!\
  # use : logiciels() call
  has_many :_logiciels, :through => :versions, :group =>
    'logiciels.id', :source => 'logiciel', :order => 'logiciels.name ASC'

end
