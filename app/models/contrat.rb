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
  belongs_to :rule, :polymorphic => true
  validates_presence_of :client, :rule, :mailinglist
  validates_length_of :mailinglist, :in => 3..50

  Rules = [ 'TimeTicket', 'Ossa' ]

  def self.set_scope(contrat_ids)
    self.scoped_methods << { :find => { :conditions =>
        [ 'contrats.id IN (?)', contrat_ids ] } }
  end


  def interval_in_seconds
    return (heure_fermeture - heure_ouverture) * 1.hour
  end

  def interval
    heure_fermeture - heure_ouverture
  end

  # We have open clients which can declare
  # requests on everything. It's with the "socle" field.
  def logiciels
    if rule_type == 'Ossa' and rule.max == -1
      return Logiciel.find(:all)
    end
    self._logiciels
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
    conditions = [ 'demandes.contrat_id = ?', id]
    # WHERE (demandes_paquets.demande_id = 62 )
    Demande.find(:all, :conditions => conditions)
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

  def name
    "#{client.name} - #{rule.name}"
  end

  # used internally by wrapper :
  # /!\ DO NOT USE DIRECTLY /!\
  # use : logiciels() call
  has_many :_logiciels, :through => :paquets, :group =>
    'id', :source => 'logiciel', :order => 'logiciels.name ASC'

  # alias_method :to_s, :name
end
