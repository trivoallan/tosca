#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Client < ActiveRecord::Base
  belongs_to :photo
  has_many :beneficiaires
  has_many :contrats, :dependent => :destroy
  belongs_to :support
  has_many :classifications
  has_many :documents

  has_many :paquets, :through => :contrats, :include => [:arch,:conteneur]
  has_many :demandes, :through => :beneficiaires # , :source => :demandes


  def ingenieurs
    return [] if contrats.empty?
    Ingenieur.find(:all,
                   :conditions => 'contrats_ingenieurs.contrat_id IN ' +
                     "(#{contrats.collect{|c| c.id}.join(',')})",
                   :joins => 'INNER JOIN contrats_ingenieurs ON ' +
                     'contrats_ingenieurs.ingenieur_id=ingenieurs.id'
                   )
  end

  def logiciels
    return [] if contrats.empty?
    Logiciel.find(:all,
                  :conditions => "logiciels.id IN (" +
                    "SELECT DISTINCT paquets.logiciel_id FROM " + 
                    "paquets WHERE paquets.contrat_id IN (" + 
                    contrats.collect{|c| c.id}.join(',') + "))",
                  :order => 'nom'
                  )
  end

  def correctifs
    return [] if demandes.empty?
    Correctif.find(:all, 
                   :conditions => "correctifs.id IN (" + 
                     "SELECT DISTINCT demandes.correctif_id FROM demandes " +
                     "WHERE demandes.beneficiaire_id IN (" +
                     beneficiaires.collect{|c| c.id}.join(',') + "))"
                   )
  end

  def typedemandes
    joins = 'INNER JOIN engagements ON engagements.typedemande_id = typedemandes.id '
    joins << 'INNER JOIN contrats_engagements ON engagements.id = contrats_engagements.engagement_id'
    conditions = [ 'contrats_engagements.contrat_id IN (' +
        'SELECT contrats.id FROM contrats WHERE contrats.client_id = ?)', id ]
    Typedemande.find(:all, 
                     :select => "DISTINCT typedemandes.*",
                     :conditions => conditions, 
                     :joins => joins)
  end

  def to_param
    "#{id}-#{nom.gsub(/[^a-z1-9]+/i, '-')}"
  end


end
