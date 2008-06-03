class Client < ActiveRecord::Base
  # Small utils for inactive, located in /lib/inactive_record.rb
  include InactiveRecord

  belongs_to :image
  has_many :beneficiaires, :dependent => :destroy
  has_many :active_recipients, :class_name => 'Beneficiaire', :include => :user,
    :conditions => 'users.inactive = 0'
  has_many :contrats, :dependent => :destroy
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


  def find_socles_select
    options = { :conditions => [ "clients_socles.client_id = ?", self.id ],
      :joins =>
      'INNER JOIN clients_socles ON clients_socles.socle_id=socles.id'}
    Socle.find(:all, options).collect{|s| [ s.name, s.id ] }
  end


  # TODO : it's slow & ugly
  # returns true if we have a contract to support an entire distribution
  # for this client, false otherwise.
  def support_distribution
    result = false
    self.contrats.each { |c| result = true if c.rule.max == -1 }
    result
  end

  def beneficiaire_ids
    @benefs ||= self.beneficiaires.find(:all, :select => 'id').collect{|c| c.id}
  end

  def ingenieurs
    return [] if contrats.empty?
    options = { :include => [:user],
      :conditions => [ 'cu.contrat_id IN (?)', contrat_ids ],
      :joins => 'INNER JOIN contrats_users cu ON cu.user_id=users.id' }
    Ingenieur.find(:all, options)
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

  # specialisation, since a Client can be "inactive".
  def find_select(options = { })
    find_active4select(options)
  end

end
