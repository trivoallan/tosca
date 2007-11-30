#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Contrat < ActiveRecord::Base
  acts_as_reportable
  has_many :paquets, :dependent => :destroy
  belongs_to :client
  has_and_belongs_to_many :engagements, :order =>
    'typedemande_id, severite_id', :include => [:severite,:typedemande]
  has_and_belongs_to_many :ingenieurs, :order => 'contrat_id'

  has_many :binaires, :through => :paquets
  has_many :appels
  validates_presence_of :type

  # The first contract in this list is the default one
  List = [ Contrat::Ossa, Contrat::Support ]

  def self.set_scope(contrat_ids)
    self.scoped_methods << { :find => { :conditions =>
        [ 'contrats.id IN (?)', contrat_ids ]} }
  end

  # We have open clients which can declare
  # requests on everything. It's with the "socle" field.
  def logiciels
    (self.socle? ? Logiciel.find(:all) : self._logiciels)
  end

  def ouverture_formatted
    d = @attributes['ouverture']
    "#{d[8,2]}.#{d[5,2]}.#{d[0,4]}"
  end

  def cloture_formatted
    d = @attributes['cloture']
    "#{d[8,2]}.#{d[5,2]}.#{d[0,4]}"
  end

  def find_engagement(request)
    options = { :conditions =>
      [ 'engagements.typedemande_id = ? AND severite_id = ?',
        request.typedemande_id, request.severite_id ] }
    self.engagements.find(:first, options)
  end

  def demandes
    joins = 'INNER JOIN demandes_paquets ON demandes.id = demandes_paquets.demande_id '
    joins << 'INNER JOIN paquets ON paquets.id = demandes_paquets.paquet_id '
    conditions = [ 'paquets.contrat_id = ?', id]
    select = 'DISTINCT demandes.*'
    # WHERE (demandes_paquets.demande_id = 62 )
    Demande.find(:all,
                 :conditions => conditions,
                 :joins => joins,
                 :select => select)
  end

  def typedemandes
    joins = 'INNER JOIN engagements ON engagements.typedemande_id = typedemandes.id '
    joins << 'INNER JOIN contrats_engagements ON engagements.id = contrats_engagements.engagement_id'
    conditions = [ 'contrats_engagements.contrat_id = ? ', id ]
    Typedemande.find(:all,
                     :select => "DISTINCT typedemandes.*",
                     :conditions => conditions,
                     :joins => joins)
  end

  INCLUDE = [:client]
  ORDER = 'clients.name ASC'
  OPTIONS = { :include => INCLUDE, :order => ORDER }

  def to_s
    name
  end

  def class_type=(value)
    self[:type] = value
  end

  def class_type
    return self[:type]
  end


  # used internally by wrapper :
  # /!\ DO NOT USE DIRECTLY /!\
  # use : logiciels() call
  has_many :_logiciels, :through => :paquets, :group =>
    'id', :source => 'logiciel', :order => 'logiciels.name ASC'

  # alias_method :to_s, :name
end
