#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Client < ActiveRecord::Base
  belongs_to :image
  has_many :beneficiaires, :dependent => :destroy
  has_many :active_recipients, :class_name => 'Beneficiaire',
    :conditions => 'beneficiaires.inactive = 0'
  has_many :contrats, :dependent => :destroy,
    :include => Contrat::INCLUDE, :order => Contrat::ORDER
  belongs_to :support
  has_many :documents, :dependent => :destroy

  has_and_belongs_to_many :socles

  has_many :paquets, :through => :contrats, :include => Paquet::INCLUDE
  has_many :demandes, :through => :beneficiaires # , :source => :demandes

  validates_presence_of :nom
  validates_length_of :nom, :in => 3..50
  # We can have, for the moment, one ml for multiple clients.
  # validates_uniqueness_of :mailingliste


  SELECT_OPTIONS = { :include => {:beneficiaires => [:identifiant]},
    :conditions => 'clients.inactive = 0 AND identifiants.inactive = 0' }

  after_save :desactivate_recipients

  # TODO : rework: to slow /!\
  # better : # UPDATE identifiants SET inactive = ? WHERE ... 
  def desactivate_recipients
    beneficiaires.each do |b|
      b.identifiant.update_attribute :inactive, inactive?
    end
  end

  def self.content_columns
    @content_columns ||= columns.reject { |c|
      c.primary || c.name =~ /(_id|_count|adresse|photo|chrono|inactive)$/
    }
  end

  # don't use this function outside of an around_filter
  def self.set_scope(client_ids)
    self.scoped_methods << { :find => { :conditions =>
        [ 'clients.id IN (?)', client_ids ]} }
  end

  def contrat_ids
    self.contrats.find(:all, :select => 'id').collect{|c| c.id}
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
    @benefs ||= self.beneficiaires.find(:all, :select => 'id').collect{|c| c.id}
  end

  def ingenieurs
    return [] if contrats.empty?
    options = { :include => [:identifiant],
      :conditions => [ 'contrats_ingenieurs.contrat_id IN (?)', contrat_ids ],
      :joins => 'INNER JOIN contrats_ingenieurs ON contrats_ingenieurs.ingenieur_id=ingenieurs.id' }
    ingenieurs = Ingenieur.find(:all, options)
    ingenieurs.uniq! if contrats.size > 1
    ingenieurs
  end

  # TODO et le support socle entier ?
  def logiciels
    return [] if contrats.empty?
    return contrats.first.logiciels if contrats.size == 1
    # speedier if there is one openbar contract
    contrats.each{|c| return Logiciel.find(:all) if c.socle? }
    # default case, when there is an association with packages stored.
    conditions = [ 'logiciels.id IN (SELECT DISTINCT paquets.logiciel_id ' + 
                   ' FROM paquets WHERE paquets.contrat_id IN (?)) ', 
                   contrats.collect{ |c| c.id } ]
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
    Severite.find(:all)
  end

  # pretty urls for client
  def to_param
    "#{id}-#{read_attribute(:nom).gsub(/[^a-z1-9]+/i, '-')}"
  end

  # can return an htmled name if deactivated
  def nom
    value = read_attribute(:nom)
    return "<strike>" << value << "</strike>" if read_attribute(:inactive)
    value
  end

  # will always be clean
  def nom_clean
    read_attribute(:nom)
  end

  def to_s
    nom
  end

end
