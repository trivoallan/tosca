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

  has_many :attachments
  has_many :documents
  has_many :comments
  has_many :managed_contracts, :class_name => 'Contract', :foreign_key => :manager_id

  has_one :ingenieur, :dependent => :destroy
  has_one :recipient, :dependent => :destroy

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

  def manager?
    role_id <= 2
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
    client = nil
    client = Client.find(client_id.to_i) unless client_id.nil?
    self.recipient = Recipient.new(:user => self, :client => client)
    self.client = true
  end

  # Associate current User to an Engineer profile
  def associate_engineer()
    self.ingenieur = Ingenieur.new(:user => self)
    self.client = false
  end

  SELECT_OPTIONS = { :include => [:user], :order =>
    'users.name ASC', :conditions => 'users.inactive = 0' }
  EXPERT_OPTIONS = { :conditions => 'users.client = 0 AND users.inactive = 0',
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

  # Pour la gestion des roles/perms :

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
    self.contracts.collect &:id
  end

  def client_ids
    res = self.contracts.collect &:client_id
    res.uniq!
    res
  end

  def kind
    (client? ? 'recipient' : 'expert')
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

end
