#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require 'digest/sha1'

class Identifiant < ActiveRecord::Base

  belongs_to :photo
  has_many :piecejointes
  has_and_belongs_to_many :roles
  has_many :documents

  has_one :ingenieur
  has_one :beneficiaire
  # TODO : vérifier que l'email est valide, et rattraper l'erreur si l'envoi de mail échoue !!!


  def self.authenticate(login, pass, crypt)
    Identifiant.with_exclusive_scope() do
      if crypt == 'false'
        Identifiant.find(:first, :conditions => ["login = ? AND password = ?", login, sha1(pass)])
      else
        Identifiant.find(:first, :conditions => ["login = ? AND password = ?", login, pass])
      end
    end
  end

  def change_password(pass)
    update_attribute "password", self.class.sha1(pass)
  end

  # Pour la gestion des roles/perms :

  # Return true/false if User is authorized for resource.
  def authorized?(resource)
    match=false

    permission_strings.each do |p|
      r = Regexp.new(p)
      match = match || ((r =~ resource) != nil)
    end
    return match
  end

  # Load permission strings
  def permission_strings
    return @permissions if @permissions
    @permissions = []
    self.roles.each{|r| r.permissions.each{|p| @permissions << p.name }}
    @permissions
  end

  # Vérifie l'intégrité/la validité d'un utilisateur
  # à utiliser à la crétion et à la modification d'un utilisateur
  # - cohérence des droits en fonction de l'appartenance (ingénieur ou bénéficiaire)
  def valide
    # cohérence des droits en fonction de l'appartenance (ingénieur ou bénéficiaire)
    # return false if beneficiaire && ( roles != [Role.find(2)] )
    # si tout va bien
    return true
  end

  # Ce qui suit est protected
  protected

  def self.sha1(pass)
    Digest::SHA1.hexdigest("linagora--#{pass}--")
  end

  before_create :crypt_password


  def crypt_password
    write_attribute("password", self.class.sha1(password))
  end

  validates_length_of :login, :within => 3..40
  validates_length_of :password, :within => 5..40
  validates_presence_of :login, :password, :password_confirmation
  validates_uniqueness_of :login, :on => :create
  validates_confirmation_of :password, :on => :create

end
