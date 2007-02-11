#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Ingenieur < ActiveRecord::Base
  belongs_to :identifiant, :dependent => :destroy
  has_and_belongs_to_many :competences
  has_and_belongs_to_many :contrats
  has_and_belongs_to_many :projets
  has_many :demandes
  has_many :interactions

  def self.content_columns
    @content_columns ||= columns.reject { |c| c.primary || 
        c.name =~ /(_id|_on|_count|chef_de_projet|expert_ossa)$/ || c.name == inheritance_column }       
  end


  def self.find_ossa(*args)
    conditions = ['ingenieurs.expert_ossa = ?', 1 ]
    Ingenieur.with_scope({:find => {:conditions => conditions }}) { 
      Ingenieur.find(*args)
    }
  end

  def self.find_presta(*args)
    conditions = ['ingenieurs.expert_ossa = ?', 0 ]
    Ingenieur.with_scope({:find => {:conditions => conditions }}) {
      Ingenieur.find(*args)
    }
  end

  # ne pas oublier de faire :include => [:identifiant] si vous 
  # appeler cette fonction, durant le Ingenieur.find
  def nom
    @nom ||= Identifiant.find(identifiant_id, :select => 'identifiants.nom').nom
    @nom
  end

  alias_method :to_s, :nom
end
