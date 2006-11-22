require 'digest/sha1'

class Identifiant < ActiveRecord::Base

  belongs_to :photo
  has_many :piecejointes
  has_and_belongs_to_many :roles
  has_many :documents
  # migration 006 :
  has_many :demandechanges

  # TODO : vérifier que l'email est valide, et rattraper l'erreur si l'envoi de mail échoue !!!

  def ingenieur?
    #si la recherche d'un ingenieur n'est pas nulle : true
    return Ingenieur.count(['identifiant_id = ?', id ]) > 0
  end

  def ingenieur
    if ingenieur?
      Ingenieur.find_by_identifiant_id(id)
    else
      nil
    end
  end

  def beneficiaire?
    #si la recherche d'un beneficiaire n'est pas nulle : true
    return Beneficiaire.count(['identifiant_id = ?', id ]) > 0
  end

  def beneficiaire
    if beneficiaire?
      Beneficiaire.find_by_identifiant_id(id) 
    else
      nil
    end
  end


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
  #def authorized?(resource)
  #  return permission_strings.include?(resource)
  #end

  # Load permission strings 
  def permission_strings
    a = []
    self.roles.each{|r| r.permissions.each{|p| a<< p.name }}
    a
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
