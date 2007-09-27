#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require 'digest/sha1'

class Identifiant < ActiveRecord::Base
  acts_as_reportable
  belongs_to :image
  has_many :piecejointes
  has_and_belongs_to_many :roles
  has_many :documents

  has_one :ingenieur
  has_one :beneficiaire
  has_one :preference

  validates_length_of :login, :within => 3..40
  validates_presence_of :login, :password
  validates_uniqueness_of :login

  attr_accessor :pwd_confirmation

  N_('Identifiant|Pwd')
  N_('Identifiant|Pwd confirmation')

  def pwd
    @pwd
  end

  def pwd=(pass)
    @pwd = pass
    return if pass.blank?
    self.password = Identifiant.sha1(pass)
  end

  # Eck ... We must add message manually in order to
  # not have the "pwd" prefix ... TODO : find a pretty way ?
  # TODO : check if gettext is an answer ?
  def validate
    errors.add_to_base(_("Password missing")) if password.blank?
    if pwd != pwd_confirmation
      errors.add_to_base(_('Password is different from its confirmation'))
    end
    unless pwd.blank?
      if pwd.length > 20
        errors.add_to_base(_('Your password is too long (max. 20)'))
      elsif pwd.length < 5
        errors.add_to_base(_('Your password is too short (min. 5)'))
      end
    end
  end

  # TODO : vérifier que l'email est valide, et
  # rattraper l'erreur si l'envoi de mail échoue !!!
  # TODO 2 : créer un ingénieur ossa ou presta selon le rôle choisi
  def create_person(client)
    if self.client
      Beneficiaire.create(:identifiant => self, :client => client)
    else
      Ingenieur.create(:identifiant => self)
    end
  end

  SELECT_OPTIONS = { :include => [:identifiant],
    :order => 'identifiants.nom ASC', :conditions => 'identifiants.inactive = 0' }

  def self.authenticate(login, pass, crypt)
    Identifiant.with_exclusive_scope() do
      pass = sha1(pass) if crypt == 'false'
      user = Identifiant.find(:first, :conditions => ['login = ? AND password = ?',
                                                      login, pass])
      return nil if user and user.inactive
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

  # Load permission strings
  def permission_strings
    return @permissions if @permissions
    @permissions = []
    self.roles.each{|r| r.permissions.each{|p| @permissions << Regexp.new(p.name) }}
    @permissions
  end

  def nom
    strike(:nom)
  end

  def login
    strike(:login)
  end

  private
  def self.sha1(pass)
    Digest::SHA1.hexdigest("linagora--#{pass}--")
  end

  # For Ruport :
  def beneficiaire_client_nom
    beneficiaire.client.nom if beneficiaire
  end

  def roles_join
    roles.join(', ')
  end

  def strike(attribute)
    value = read_attribute(attribute)
    return "<strike>" << attribute << "</strike>" if inactive?
    value
  end
end
