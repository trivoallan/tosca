class Contract < ActiveRecord::Base
  belongs_to :client
  belongs_to :rule, :polymorphic => true
  belongs_to :creator, :class_name => 'User'
  belongs_to :salesman, :class_name => 'Ingenieur'

  has_many :demandes
  has_many :appels
  has_many :tags
  has_many :releases

  has_and_belongs_to_many :commitments, :uniq => true, :order =>
    'typedemande_id, severite_id', :include => [:severite,:typedemande]
  has_and_belongs_to_many :users, :order => 'users.name', :uniq => true
  # Those 2 ones are helpers, not _real_ relation ship
  has_and_belongs_to_many :engineer_users, :class_name => 'User',
    :conditions => 'users.client = 0',
    :order => 'users.name ASC'
  has_and_belongs_to_many :recipient_users, :class_name => 'User',
    :conditions => 'users.client = 1', :include => :recipient,
    :order => 'users.name ASC'
  has_and_belongs_to_many :teams, :order => 'teams.name', :uniq => true
  has_and_belongs_to_many :versions, :order => 'versions.name DESC', :uniq => true

  validates_presence_of :client, :rule, :creator
  validates_numericality_of :opening_time, :closing_time,
    :only_integer => true
  validates_inclusion_of :opening_time, :closing_time, :in => 0..24

  validate :must_open_before_close

  def must_open_before_close
    valid = true
    if self.opening_time > self.closing_time
      self.errors.add_to_base("The schedules of this contract are invalid.")
      valid = false
    end
    valid
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
    return (closing_time - opening_time) * 1.hour
  end

  def interval
    closing_time - opening_time
  end

  # We have open clients which can declare
  # requests on everything. It's with the "socle" field.
  def logiciels
    if rule_type == 'Rules::Component' and rule.max == -1
      return Logiciel.find(:all, :order => 'logiciels.name ASC')
    end
    Logiciel.find(:all, :conditions => { "contracts.id" => self.id },
      :joins => { :versions => :contracts },
      :group => "versions.logiciel_id")
  end

  # TODO : I am sure it could be better. Rework model ???
  def find_recipients_select
    options = { :conditions => 'users.inactive = 0' }
    self.recipient_users.find(:all, options).collect{|u|
      [  u.name, u.recipient.id ] if u.recipient }
  end

  def start_date_formatted
    display_time read_attribute(:start_date)
  end

  def end_date_formatted
    display_time read_attribute(:end_date)
  end

  def find_commitment(request)
    options = { :conditions =>
      [ 'commitments.typedemande_id = ? AND severite_id = ?',
        request.typedemande_id, request.severite_id ] }
    self.commitments.find(:first, options)
  end

  def typedemandes
    joins = 'INNER JOIN commitments ON commitments.typedemande_id = typedemandes.id '
    joins << 'INNER JOIN commitments_contracts ON commitments.id = commitments_contracts.commitment_id'
    conditions = [ 'commitments_contracts.contract_id = ? ', id ]
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
    specialisation = read_attribute(:name)
    res = "#{client.name} - #{rule.name}"
    res << " - #{specialisation}" unless specialisation.blank?
    res
  end

end
