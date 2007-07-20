#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Logiciel < ActiveRecord::Base
  acts_as_reportable
  has_many :contributions
  has_and_belongs_to_many :competences
  has_many :demandes
  has_many :urllogiciels, :dependent => :destroy
  has_many :paquets, :order => "version DESC", :dependent => :destroy
  #belongs_to :communaute
  belongs_to :license
  belongs_to :groupe
  belongs_to :image, :dependent => :destroy

  has_many :binaires, :through => :paquets, :dependent => :destroy

  validates_length_of :competences, :minimum => 1, :message => 
    _('You have to specify at least one technology')

  def self.set_scope(contrat_ids)
    self.scoped_methods << { :find => { :conditions => 
        [ 'paquets.contrat_id IN (?)', contrat_ids ],
        :include => [:paquets]} } if contrat_ids
  end

  # TODO : l'une des deux est de trop. Normalement c'est 
  # uniquement content_columns
  def self.list_columns 
    columns.reject { |c| c.primary || 
        c.name =~ /(_id|nom|resume|description|referent)$/ || 
          c.name == inheritance_column } 
  end

  def self.content_columns
    @content_columns ||= columns.reject { |c| 
      c.primary || c.name =~ /(_id|_count|referent|Description)$/  
    }
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
