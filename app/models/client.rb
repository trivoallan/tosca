#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Client < ActiveRecord::Base
  # Small utils for inactive, located in /lib/inactive_record.rb
  include InactiveRecord

  belongs_to :image
  has_many :beneficiaires, :dependent => :destroy
  has_many :active_recipients, :class_name => 'Beneficiaire', :include => :user,
    :conditions => 'users.inactive = 0', :dependent => :destroy
  has_many :contrats, :class_name => 'Contrat', :include => [:client],
    :dependent => :destroy, :order => 'clients.name'
  has_many :documents, :dependent => :destroy

  has_and_belongs_to_many :socles

  has_many :paquets, :through => :contrats, :include => Paquet::INCLUDE
  has_many :demandes, :through => :beneficiaires # , :source => :demandes

  validates_presence_of :name
  validates_length_of :name, :in => 3..50


  SELECT_OPTIONS = { :include => {:beneficiaires => [:user]},
    :conditions => 'clients.inactive = 0 AND users.inactive = 0' }

  after_save :desactivate_recipients

  def desactivate_recipients
    begin
      connection.begin_db_transaction
      value = (inactive? ? 1 : 0)
      connection.update "UPDATE users u, beneficiaires b SET u.inactive = #{value} WHERE b.client_id=#{self.id} AND b.user_id=u.id"
      connection.commit_db_transaction
    rescue Exception => e
      connection.rollback_db_transaction
      errors.add_to_base(_('Cannot (de)activate associated recipients due to : "%s"') % e.message)
      return false
    end
    true
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
    contrats.each { |c| result = true if c.rule.max == -1 }
    result
  end

  def beneficiaire_ids
    @benefs ||= self.beneficiaires.find(:all, :select => 'id').collect{|c| c.id}
  end

  def ingenieurs
    return [] if contrats.empty?
    options = { :include => [:user],
      :conditions => [ 'contrats_ingenieurs.contrat_id IN (?)', contrat_ids ],
      :joins => 'INNER JOIN contrats_ingenieurs ON contrats_ingenieurs.ingenieur_id=ingenieurs.id' }
    ingenieurs = Ingenieur.find(:all, options)
    ingenieurs.uniq! if contrats.size > 1
    ingenieurs
  end


  def logiciels
    return [] if contrats.empty?
    return contrats.first.logiciels if contrats.size == 1
    # speedier if there is one openbar contract
    contrats.each{|c| return Logiciel.find(:all) if c.rule.max == -1 }
    # default case, when there is an association with packages stored.
    conditions = [ 'logiciels.id IN (SELECT DISTINCT paquets.logiciel_id ' +
                   ' FROM paquets WHERE paquets.contrat_id IN (?)) ',
                   contrats.collect{ |c| c.id } ]
    Logiciel.find(:all, :conditions => conditions, :order => 'logiciels.name')
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
    "#{id}-#{read_attribute(:name).gsub(/[^a-z1-9]+/i, '-')}"
  end

  # can return an htmled name if deactivated
  def name
    strike(:name)
  end

  # will always be clean
  def name_clean
    read_attribute(:name)
  end

end
