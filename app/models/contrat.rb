#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Contrat < ActiveRecord::Base
  has_many :paquets, :dependent => :destroy
  belongs_to :client
  has_and_belongs_to_many :engagements, :order => "typedemande_id, severite_id"
  has_and_belongs_to_many :ingenieurs, :order => 'contrat_id'

  has_many :logiciels, :through => :paquets, :group => 'id', :order => 'nom ASC'

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

  def nbpaquets
    Paquet.count([ "contrat_id = ?", id ])
  end

end
