#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require 'digest/sha1'
require 'ruport'

class User < ActiveRecord::Base
  # Small utils for inactive & password, located in /lib/*.rb
  include InactiveRecord
  include PasswordGenerator

  acts_as_reportable
  belongs_to :image
  has_many :piecejointes
  belongs_to :role
  has_many :documents

  has_one :ingenieur, :dependent => :destroy
  has_one :beneficiaire, :dependent => :destroy
  has_one :preference, :dependent => :destroy

  has_and_belongs_to_many :contrats

  validates_length_of :login, :within => 3..20
  validates_length_of :password, :within => 5..40
  validates_presence_of :login, :password, :role
  validates_uniqueness_of :login

  attr_accessor :pwd_confirmation

  N_('User|Pwd')
  N_('User|Pwd confirmation')

  def pwd
    @pwd
  end

  def pwd=(pass)
    @pwd = pass
    return if pass.blank? or pass.length < 5 or pass.length > 40
    self.password = User.sha1(pass)
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
  def self.set_scope(contrat_ids)
    if contrat_ids
      self.scoped_methods << { :find => { :conditions =>
          [ 'cu.contrat_id IN (?) ', contrat_ids ], :joins =>
        'INNER JOIN contrats_users cu ON cu.user_id=users.id ' } }
    end
  end


  # Warning : this method update the current User object
  def create_person(client)
    if client
      Beneficiaire.create(:user => self, :client => client)
      self.update_attribute(:client, true)
    else
      Ingenieur.create(:user => self)
      self.update_attribute(:client, false)
    end
  end

  SELECT_OPTIONS = { :include => [:user], :order =>
    'users.name ASC', :conditions => 'users.inactive = 0' }

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

    permission_strings.each do |r|
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

  # cached, coz' it's used in scopes
  def contrat_ids
    @contrat_ids ||= self.contrats.find(:all, :select => 'id').collect {|c| c.id}
  end

  # cached, coz' it's used in scopes
  def client_ids
    @client_ids ||= self.contrats.find(:all, :group => 'client_id',
         :select => 'client_id').collect {|c| c.client_id}
  end


  private
  # Load permission strings
  # TODO : cache this method. Since we have few roles, it's possible
  # to use a table or a hash.
  # See app/helpers/static_image/rb#self.severite for a bad sample
  # See http://api.rubyonrails.com/classes/ActiveSupport/CachingTools/HashCaching.html#M000319 for a better way
  # See also http://api.rubyonrails.com/classes/ActiveSupport/CachingTools/HashCaching.html#M000319 for a complete overview
  def permission_strings
    return @permissions if @permissions
    @permissions = self.role.permissions.collect{|p| Regexp.new(p.name) }
    @permissions
  end

  def self.sha1(pass)
    Digest::SHA1.hexdigest("linagora--#{pass}--")
  end

  # For Ruport :
  def beneficiaire_client_name
    beneficiaire.client.name if beneficiaire
  end

  def role_name
    role.name if role
  end

end
