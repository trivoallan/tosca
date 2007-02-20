#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Logiciel < ActiveRecord::Base

  has_many :contributions
  has_many :classifications
  has_and_belongs_to_many :competences
  has_and_belongs_to_many :projets
  has_many :demandes
  has_many :urllogiciels, :dependent => :destroy
  has_many :paquets, :order => "version DESC", :dependent => :destroy
  #belongs_to :communaute
  has_many :interactions
  belongs_to :license
  belongs_to :groupe

  has_many :binaires, :through => :paquets, :dependent => :destroy

  validates_presence_of :competences => 
    "Vous devez spécifier au moins une compétence" 

  def self.set_scope(contrat_ids)
    self.scoped_methods << { :find => { :conditions => 
        [ 'paquets.contrat_id = ?', contrat_ids ],
        :include => [:paquets]} }
  end



  def self.list_columns 
    columns.reject { |c| c.primary || 
        c.name =~ /(_id|nom|resume|description|referent)$/ || 
          c.name == inheritance_column } 
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
