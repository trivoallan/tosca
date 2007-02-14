#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Logiciel < ActiveRecord::Base

  has_many :correctifs
  has_many :classifications
  has_and_belongs_to_many :competences
  has_and_belongs_to_many :projets
  has_many :demandes
  has_many :urllogiciels, :dependent => :destroy
  has_many :paquets, :order => "version DESC", :dependent => :destroy
  #belongs_to :communaute
  has_many :interactions
  belongs_to :license

  has_many :binaires, :through => :paquets, :dependent => :destroy

  validates_presence_of :competences => 
    "Vous devez spécifier au moins une competence" 

  def self.list_columns 
    columns.reject { |c| c.primary || 
        c.name =~ /(_id|nom|resume|description|referent)$/ || 
          c.name == inheritance_column } 
  end

  def count_mes_paquets(beneficiaire)
    if beneficiaire
      Paquet.count(:all, :conditions => 
                     "contrat_id IN (#{contrats.collect{|c| c.id}.join(',')})")
    else
      Paquet.count(:all, :conditions => "logiciel_id = #{id}")
    end
  end

  def to_param
    "#{id}-#{nom.gsub(/[^a-z1-9]+/i, '-')}"
  end

  def to_s
    nom
  end
  
  def self.not_found
    '(Inconnu)'
  end

end
