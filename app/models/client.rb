#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Client < ActiveRecord::Base
  belongs_to :photo
  has_many :beneficiaires, :dependent => :destroy
  has_many :contrats, :dependent => :destroy, 
    :include => Contrat::INCLUDE, :order => Contrat::ORDER
  belongs_to :support
  has_many :documents, :dependent => :destroy

  has_and_belongs_to_many :socles

  has_many :paquets, :through => :contrats, :include => Paquet::INCLUDE
  has_many :demandes, :through => :beneficiaires # , :source => :demandes


  # don't use this function outside of an around_filter
  def self.set_scope(client_ids)
    self.scoped_methods << { :find => { :conditions => 
        [ 'clients.id IN (?)', client_ids ]} }
  end

  # TODO : c'est pas DRY
  def contrat_ids
    contrats = self.contrats.find(:all, :select => 'id').collect{|c| c.id}
    return (contrats.empty? ? '0' : contrats.join(','))
  end

  # TODO : c'est lent et moche
  # returns true if we have a contract to support an entire distribution 
  # for this client, false otherwise.
  def support_distribution
    contrats = self.contrats.find(:all, :select => 'socle')
    result = false
    contrats.each { |c| result = true if c.socle }
    result
  end


  def beneficiaire_ids
    benefs = self.beneficiaires.find(:all, :select => 'id').collect{|c| c.id}
    return (benefs.empty? ? '0' : benefs.join(','))
  end


  def ingenieurs
    return [] if contrats.empty?
    Ingenieur.find(:all,
                   :conditions => 'contrats_ingenieurs.contrat_id IN ' +
                     "(#{contrats.collect{|c| c.id}.join(',')})",
                   :joins => 'INNER JOIN contrats_ingenieurs ON ' +
                     'contrats_ingenieurs.ingenieur_id=ingenieurs.id',
                   :include => [:identifiant]
                   )
  end

  def logiciels
    return [] if contrats.empty?
    # Voici le hack pour permettre au client Linagora d'avoir tous les softs
    return Logiciel.find_all if self.id == 4 
    conditions = 'logiciels.id IN (SELECT DISTINCT paquets.logiciel_id FROM ' + 
      'paquets WHERE paquets.contrat_id IN (' + 
      contrats.collect{|c| c.id}.join(',') + '))'
    Logiciel.find(:all, :conditions => conditions, :order => 'logiciels.nom')
  end

  def contributions
    return [] if demandes.empty?
    Contribution.find(:all, 
                   :conditions => "contributions.id IN (" + 
                     "SELECT DISTINCT demandes.contribution_id FROM demandes " +
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

  # TODO : à revoir, on pourrait envisager de moduler les sévérités selon 
  # les type de demandes
  def severites
    Severite.find_all
  end

  def to_param
    "#{id}-#{nom.gsub(/[^a-z1-9]+/i, '-')}"
  end

  def to_s
    nom
  end

end
