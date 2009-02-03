#
# Copyright (c) 2006-2009 Linagora
#
# This file is part of Tosca
#
# Tosca is free software, you can redistribute it and/or modify
# it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
# Tosca is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
require 'digest/sha1'

class User < ActiveRecord::Base
  # Small utils for inactive & password, located in /lib/*.rb
  include InactiveRecord
  include PasswordGenerator
  include LdapTosca

  belongs_to :picture, :dependent => :destroy
  belongs_to :role
  belongs_to :team
  belongs_to :client

  has_many :attachments, :through => :comments
  has_many :comments, :dependent => :destroy
  has_many :assigned_issues, :dependent => :destroy, :foreign_key => :recipient_id,
    :dependent => :destroy, :class_name => 'Issue'
  has_many :managed_contracts, :class_name => 'Contract', :foreign_key => :tam_id

  has_many :knowledges, :order => 'knowledges.level DESC', :foreign_key => :engineer_id,
    :dependent => :destroy
  has_many :subscriptions, :dependent => :destroy

  has_and_belongs_to_many :own_contracts, :class_name => 'Contract', :order => :id

  validates_length_of :login, :within => 3..20
  validates_length_of :password, :within => 5..40
  validates_presence_of :login, :password, :role, :email, :name
  validates_uniqueness_of :login

  attr_accessor :pwd_confirmation

  I18n.t('User|Pwd')
  I18n.t('User|Pwd confirmation')

  #Preferences
  preference :digest_daily, :default => false
  preference :digest_weekly, :default => false
  preference :digest_monthly, :default => false

  def pwd
    @pwd
  end

  def pwd=(pass)
    @pwd = pass
    return if pass.blank? or pass.length < 5 or pass.length > 40
    self.password = User.sha1(pass)
  end

  #Specific methods used in forms
  #TODO: find a better way
  def client_form
    recipient?
  end
  def client_form=(client)
    #Nothing to do
  end

  def manager?
    role_id <= 2
  end

  def trigram
    return @trigram if @trigram
    names = name.split(/ |-/)
    case names.size
    when 0..1 # ["Admin"] => ADM
      @trigram = self.login[0..2].upcase!
    when 2 # ["Jon", "Toto"] => JTO
      @trigram = (b.first.first + b.last.first).upcase!
    else # ["Jon", "Michael", "Toto"] => JMT
      @trigram = (b.first.first + b[1].first + b.last.first).upcase!
    end
    @trigram
  end

  # TODO : this formatting method has to be in an helper, a lib or a plugin.
  # /!\ but NOT here /!\
  before_save do |record|
    ### NUMBERS #########################################################
    number = record.phone.to_s
    number.upcase!
    if number =~ /\d{10}/ #0140506070
      number.gsub!(/(\d\d)/, '\1.').chop!
    elsif number =~ /\d\d(\D\d\d){4}/ #01.40_50f60$70
      number.gsub!(/\D/, ".")
    end
    record.phone = number
    # false will invalidate the save
    true
  end

  after_save do |record|
    # To make sure we have only one time a engineer
    if record.team
      record.own_contracts -= record.team.contracts
    end
    true
  end

  after_create :do_after_create
  def do_after_create
    Notifier::deliver_user_signup(self)
    true
  end

  # Eck ... We must add message manually in order to
  # not have the "pwd" prefix ... TODO : find a pretty way ?
  # TODO : check if gettext is an answer ?
  def validate
    errors.add(:pwd, I18n.t("Password missing")) if password.blank?
    if pwd != pwd_confirmation
      errors.add(:pwd_confirmation, I18n.t('Password is different from its confirmation'))
    end
    unless pwd.blank?
      if pwd.length > 40
        errors.add(:pwd, I18n.t('Your password is too long (max. 20)'))
      elsif pwd.length < 5
        errors.add(:pwd, I18n.t('Your password is too short (min. 5)'))
      end
    end
    if pwd.blank? and self.password.blank?
      errors.add(:pwd, I18n.t('You must have specify a password.'))
    end
  end

  # This reduced the scope of User to allowed contracts of current user
  def self.get_scope(contract_ids)
    { :find => { :conditions =>
          [ 'contracts_users.contract_id IN (?) ', contract_ids ], :joins =>
          'INNER JOIN contracts_users ON contracts_users.user_id=users.id ' } }
  end

  # Associate current User to a recipient profile
  def associate_recipient(client_id)
    c_id = nil
    c_id = Client.find(client_id.to_i).id unless client_id.nil?
    self.client_id = c_id
    self.save
  end

  # Associate current User to an Engineer profile
  def associate_engineer
    self.client_id = nil
    self.save
  end

  SELECT_OPTIONS = { :order => 'users.name ASC',
    :conditions => ['users.inactive = ?', false ] } unless defined? User::SELECT_OPTIONS
  EXPERT_OPTIONS = { :conditions => [ 'users.inactive = ? AND users.client_id IS NULL', false ],
    :order => 'users.name' } unless defined? User::EXPERT_OPTIONS

  # If you move/rename this method, do NOT forget to look at lib/ldap_tosca.rb /!\
  def self.authenticate(login, pass)
    user = nil
    User.with_exclusive_scope do
      conditions = ['login = ? AND password = ?', login, sha1(pass)]
      user = User.first(:conditions => conditions)
    end
    (user and user.inactive? ? nil : user)
  end

  def self.tams
    self.find_select( { :joins => :own_contracts, :group => "users.id, users.name",
        :conditions => "contracts.tam_id = users.id" } )
  end

  def self.admins
    self.all(:conditions => { :role_id => 1 })
  end

  # To manage permissions/roles :

  # Return true/false if User is authorized for resource.
  def authorized?(resource)
    match = false

    permission_strings(self.role_id).each do |r|
      if ((r =~ resource) != nil)
        match = true
        break
      end
    end
    return match
  end

  def recipient?
    not engineer?
  end

  def engineer?
    self.client_id.nil?
  end
  alias_method :expert?, :engineer?

  def self.engineers
    User.all(:conditions => 'users.client_id IS NULL')
  end

  def self.recipients
    User.all(:conditions => 'users.client_id IS NOT NULL')
  end

  def self.find_select_recipients
    options = SELECT_OPTIONS.dup
    options[:conditions][0] += ' AND users.client_id IS NOT NULL'
    User.find_select(options)
  end

  def self.find_select_by_contract_id(contract_id)
    conditions = [ 'contracts_users.contract_id = ?', contract_id ]
    options = {:find => {:conditions => conditions, :joins => :own_contracts}}
    User.send(:with_scope, options) do
      User.find_select(User::SELECT_OPTIONS)
    end
  end

  def self.find_select_engineers_by_contract_id(contract_id)
    joins = 'INNER JOIN contracts_users cu ON cu.user_id=users.id'
    conditions = [ 'cu.contract_id = ?', contract_id ]
    options = {:find => {:conditions => conditions, :joins => joins}}
    User.send(:with_scope, options) do
      User.find_select(User::EXPERT_OPTIONS)
    end
  end

  def name
    strike(:name)
  end

  # will always be clean
  def name_clean
    read_attribute(:name)
  end

  # The contracts of a User = his contracts + the contracts of his team
  def contracts
    contracts = self.own_contracts.dup
    contracts.concat(self.team.contracts) if self.team
    contracts
  end

  def active_contracts
    options = { :conditions => { :inactive => false } }
    result = self.own_contracts.all(options)
    # options are modified within a relationship finder, so we need to reset it
    options = { :conditions => { :inactive => false } }
    result.concat(self.team.contracts.all(options)) if self.team
    result
  end

  # TODO : provide a cache for those really often used & costly 2 methods
  def contract_ids
    self.contracts.collect(&:id)
  end

  def client_ids
    res = self.contracts.collect(&:client_id)
    res.uniq!
    res
  end

  def kind
    (recipient? ? 'recipient' : 'expert')
  end

  def team_manager?
    if self.team
      return self.team.contact_id == self.id
    end
    false
  end

  def self.reset_permission_strings
    @@permission_strings = Array.new(7)
  end

  def contracts_subscribed
    models_subscribed(Contract)
  end

  def issues_subscribed
    models_subscribed(Issue)
  end

  def softwares_subscribed
    models_subscribed(Software)
  end

  # Cache permission strings, not the best way
  @@permission_strings = Array.new(7)
  def permission_strings(role_id)
    @@permission_strings[role_id] ||=
      Role.find(role_id).permissions.collect{|p| Regexp.new(p.name) }
  end

  #Generate a field for an email
  #like : Toto Tutu <tutu.toto@truc.com>
  def email_name
    "#{self.name} <#{self.email}>"
  end

  def issues
    self.contracts.collect(&:issues).uniq
  end

  private
  def self.sha1(pass)
    Digest::SHA1.hexdigest("linagora--#{pass}--")
  end

  # specialisation, since an Account can be <inactive>.
  def self.find_select(options = {})
    find_active4select(options)
  end

  def models_subscribed(model)
    self.subscriptions.select { |s| s.model.is_a? model }.collect { |s| s.model }
  end
end
