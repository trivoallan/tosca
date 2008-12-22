#
# Copyright (c) 2006-2008 Linagora
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

  belongs_to :image
  belongs_to :role
  belongs_to :team
  belongs_to :client

  has_many :attachments
  has_many :documents
  has_many :comments
  has_many :issues, :dependent => :destroy, :foreign_key => :recipient_id
  has_many :managed_contracts, :class_name => 'Contract', :foreign_key => :manager_id

  has_many :knowledges, :order => 'knowledges.level DESC', :foreign_key => :engineer_id
  has_many :phonecalls
  has_many :subscriptions

  has_and_belongs_to_many :own_contracts, :class_name => "Contract"

  validates_length_of :login, :within => 3..20
  validates_length_of :password, :within => 5..40
  validates_presence_of :login, :password, :role, :email, :name
  validates_uniqueness_of :login

  attr_accessor :pwd_confirmation

  N_('User|Pwd')
  N_('User|Pwd confirmation')

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
    @trigram ||= self.login[0..2].upcase!
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

  # Eck ... We must add message manually in order to
  # not have the "pwd" prefix ... TODO : find a pretty way ?
  # TODO : check if gettext is an answer ?
  def validate
    errors.add(:pwd, _("Password missing")) if password.blank?
    if pwd != pwd_confirmation
      errors.add(:pwd_confirmation, _('Password is different from its confirmation'))
    end
    unless pwd.blank?
      if pwd.length > 40
        errors.add(:pwd, _('Your password is too long (max. 20)'))
      elsif pwd.length < 5
        errors.add(:pwd, _('Your password is too short (min. 5)'))
      end
    end
    if pwd.blank? and self.password.blank?
      errors.add(:pwd, _('You must have specify a password.'))
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
    :conditions => 'users.inactive = 0' }
  EXPERT_OPTIONS = { :conditions => 'users.inactive = 0 AND users.client_id IS NULL',
    :order => 'users.name' }

  def self.authenticate(login, pass, crypt = 'false')
    User.with_exclusive_scope() do
      pass = sha1(pass) if crypt == 'false'
      user = User.find(:first, :conditions =>
                              ['login = ? AND password = ?', login, pass])
      return nil if user and user.inactive?
      user
    end
  end

  def self.managers
   self.find_select( { :joins => :own_contracts, :group => "users.id",
     :conditions => "contracts.manager_id = users.id" } )
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
    User.find(:all, :conditions => 'users.client_id IS NULL')
  end

  def self.recipients
    User.find(:all, :conditions => 'users.client_id IS NOT NULL')
  end

  def self.find_select_recipients
    options = SELECT_OPTIONS.dup
    options[:conditions] += ' AND users.client_id IS NOT NULL'
    User.find_select(options)
  end

  def self.find_select_by_contract_id(contract_id)
    joins = 'INNER JOIN contracts_users cu ON cu.user_id=users.id'
    conditions = [ 'cu.contract_id = ?', contract_id ]
    options = {:find => {:conditions => conditions, :joins => joins}}
    User.send(:with_scope, options) do
      User.find_select(User::SELECT_OPTIONS)
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
    result = self.own_contracts.find(:all, options)
    # options are modified within a relationship finder, so we need to reset it
    options = { :conditions => { :inactive => false } }
    result.concat(self.team.contracts.find(:all, options)) if self.team
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

  private
  def self.sha1(pass)
    Digest::SHA1.hexdigest("linagora--#{pass}--")
  end

  # specialisation, since an Account can be <inactive>.
  def self.find_select(options = { })
    find_active4select(options)
  end

  def models_subscribed(model)
    self.subscriptions.select { |s| s.model.is_a? model }.collect { |s| s.model }
  end
end
