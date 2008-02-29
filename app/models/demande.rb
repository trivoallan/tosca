#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Demande < ActiveRecord::Base
  belongs_to :typedemande
  belongs_to :logiciel
  belongs_to :severite
  belongs_to :statut
  # 3 peoples involved in a request :
  #  1. The submitter (The one who has filled the request)
  #  2. The engineer (The one which is currently in charged of this request)
  #  3. The recipient (The one which has the problem)
  belongs_to :beneficiaire
  belongs_to :ingenieur
  belongs_to :submitter, :class_name => 'User',
    :foreign_key => 'submitter_id'

  belongs_to :contrat
  has_many :phonecalls
  has_one :elapsed, :dependent => :destroy
  belongs_to :contribution
  belongs_to :socle
  # TODO : there is no interface to this belongs_to /!\
  belongs_to :binaire, :include => :paquet

  has_many :commentaires, :order => "created_on ASC", :dependent => :destroy
  has_many :piecejointes, :through => :commentaires


  # Key pointers to the request history
  # /!\ used to store the description /!\
  belongs_to :first_comment, :class_name => "Commentaire",
    :foreign_key => "first_comment_id"
  # /!\ the last _public_ comment /!\
  belongs_to :last_comment, :class_name => "Commentaire",
    :foreign_key => "last_comment_id"

  # Validation
  validates_presence_of :resume, :contrat, :description, :beneficiaire,
   :statut, :severite, :warn => _("You must indicate a %s for your request")
  validates_length_of :resume, :within => 5..70
  validates_length_of :description, :minimum => 5

  validate do |record|
    if record.contrat.nil? || record.beneficiaire.nil? ||
        (record.contrat.client_id != record.beneficiaire.client_id)
      record.errors.add _('The client of this contract is not consistant with the client of this recipient.')
    end
  end

  # used for ruport. See plugins for more information
  acts_as_reportable

  # self-explanatory
  TERMINEES = "demandes.statut_id IN (#{Statut::CLOSED.join(',')})"
  EN_COURS = "demandes.statut_id IN (#{Statut::OPENED.join(',')})"

  # See ApplicationController#scope
  def self.set_scope(contract_ids)
    scope = { :find => { :conditions =>
        [ 'demandes.contrat_id IN (?)', contract_ids ] } }
    self.scoped_methods << { :find => scope, :count => scope }
  end

  def to_param
    "#{id}-#{resume.gsub(/[^a-z1-9]+/i, '-')}"
  end

  def to_s
    "#{typedemande.name} (#{severite.name}) : #{resume}"
  end

  def name
    to_s
  end

  def formatted_elapsed
    contrat.rule.formatted_elapsed(self.elapsed.until_now)
  end

  def find_other_comment(comment_id)
    cond = [ 'commentaires.prive <> 1 AND commentaires.id <> ?', comment_id ]
    self.commentaires.find(:first, :conditiions => cond)
  end

  def find_status_comment_before(comment)
    options = { :order => 'created_on DESC', :conditions =>
      [ 'commentaires.statut_id IS NOT NULL AND commentaires.created_on < ?',
        comment.created_on ]}
    self.commentaires.find(:first, options)
  end

  # set the default for a new request
  def set_defaults(expert, recipient, contracts, params)
    return if self.statut_id
    # self-assignment
    self.ingenieur = expert
    # without severity, by default
    self.severite_id = 4
    # self-contract, by default
    self.contrat_id = contracts.first.id if contracts.size == 1
    # if we came from software view, it's sets automatically
    self.logiciel_id = params[:logiciel_id]
    # recipients
    self.beneficiaire_id = recipient.id if recipient
  end

  # Description was moved to first comment mainly for performance reason
  def description
    self.first_comment.corps unless self.first_comment.blank?
  end

  def description=(value)
    first_comment = self.first_comment
    return create_first_comment(value) unless first_comment
    if first_comment and first_comment.corps != value
      first_comment.update_attribute(:corps, value)
    end
  end

  private
  def create_first_comment(value)
    self.first_comment = Commentaire.create(:corps => value,
                           :demande => self, :user_id => self.submitter_id)
  end

  public
  # /!\ Dirty Hack Warning /!\
  # We use finder for overused view mainly (demandes/list)
  # It's about 40% faster with this crap (from 2.8 r/s to 4.0 r/s)
  # it's not enough, but a good start :)
  SELECT_LIST = 'demandes.*, severites.name as severites_name, ' +
    'logiciels.name as logiciels_name, clients.name as clients_name, ' +
    'typedemandes.name as typedemandes_name, statuts.name as statuts_name '
  JOINS_LIST = 'INNER JOIN severites ON severites.id=demandes.severite_id ' +
    'INNER JOIN beneficiaires ON beneficiaires.id=demandes.beneficiaire_id '+
    'INNER JOIN clients ON clients.id = beneficiaires.client_id '+
    'INNER JOIN typedemandes ON typedemandes.id = demandes.typedemande_id ' +
    'INNER JOIN statuts ON statuts.id = demandes.statut_id ' +
    'LEFT OUTER JOIN logiciels ON logiciels.id = demandes.logiciel_id '

  def updated_on_formatted
    d = @attributes['updated_on']
    "#{d[8,2]}.#{d[5,2]}.#{d[0,4]} #{d[11,2]}:#{d[14,2]}"
  end

  def created_on_formatted
    d = @attributes['created_on']
    "#{d[8,2]}.#{d[5,2]}.#{d[0,4]} #{d[11,2]}:#{d[14,2]}"
  end

  def self.content_columns
    @content_columns ||= columns.reject { |c| c.primary ||
      c.name =~ /(_id|_on|resume)$/ ||
      c.name == inheritance_column }
  end

  def client
    @client ||= ( beneficiaire ? beneficiaire.client : nil )
    @client
  end

  # Returns the state of a request at date t
  # The result is a READ ONLY clone with the 3 indicators
  #   statut_id, ingenieur_id & severite_id
  def state_at(t)
    return self if t >= self.updated_on
    return Demande.new if t < self.created_on

    options = {:conditions => ["statut_id IS NOT NULL AND created_on <= ?", t],
      :order => "created_on DESC" }
    statut_id = self.commentaires.find(:first, options).statut_id

    options[:conditions].first = "severite_id IS NOT NULL AND created_on <= ?"
    severite_id = self.commentaires.find(:first, options).severite_id

    options[:conditions].first = "ingenieur_id IS NOT NULL AND created_on <= ?"
    com_ingenieur = self.commentaires.find(:first, options)
    ingenieur_id = com_ingenieur ? com_ingenieur.ingenieur_id : nil

    result = self.clone
    result.attributes = { :statut_id => statut_id,
      :ingenieur_id => ingenieur_id, :severite_id => severite_id }
    result.readonly!
    result
  end

  def respect_contournement(contrat_id)
    affiche_delai(temps_ecoule, engagement(contrat_id).contournement)
  end

  def respect_correction(contrat_id)
    affiche_delai(temps_ecoule, engagement(contrat_id).correction)
  end

  def affiche_temps_correction
    Time.in_words(self.elapsed.correction, self.contrat.interval)
  end

  # Retourne le délais imparti pour corriger la demande
  # TODO : validation MLO
  # TODO : inaffichable dans la liste des demandes > améliorer le calcul de ce délais
  def delais_correction
    delais = paquets.compact.collect{ |p|
      p.correction(typedemande_id, severite_id) *
      p.contrat.interval_in_seconds
    }.min
  end

  def affiche_temps_contournement
    Time.in_words(self.elapsed.workaround, self.contrat.interval)
  end

  def affiche_temps_rappel
    Time.in_words(self.elapsed.taken_into_account, self.contrat.interval)
  end

  def engagement
    return nil unless contrat_id && severite_id && typedemande_id
    conditions = [" contrats_engagements.contrat_id = ? AND " +
      "engagements.severite_id = ? AND engagements.typedemande_id = ? ",
      contrat_id, severite_id, typedemande_id ]
    joins = " INNER JOIN contrats_engagements ON engagements.id = contrats_engagements.engagement_id"
    Engagement.find(:first, :conditions => conditions, :joins => joins)
  end

  #on ne calcule qu'une fois par instance
  def temps_ecoule
    @temps_passe ||= compute_temps_ecoule
    @temps_passe
  end

  #Oui ces 2 fonctions n'ont rien à faire dans un modèle.
  # Mais l'affichage dépend du modèle (du support client)
  # donc en fait si ^_^
  #
  # if the demande is over, then return the overrun time
  # TODO : blast this method, totally.
  def time_spent_in_percent
    return 0 if
    temps = temps_ecoule
    return "sans engagement" if temps == -1

    contrats = Contrat.find(:all)
    contrats.delete_if { |contrat|
      engagement= engagement(contrat.id)
      engagement == nil or engagement.correction < 0
    }
    # A demand may have several contracts.
    # I keep the more critical correction time
    critical_contract = contrats[0]
    contrats.each do |c|
      critical_contract = c if engagement(c.id).correction < engagement(critical_contract.id).correction
    end
    # Not very DRY: present in lib/comex_resultat too
    amplitude = self.contrat.heure_fermeture - self.contrat.heure_ouverture
    if critical_contract.blank?
      temps_correction = 0.days
    else
      temps_correction = engagement( critical_contract.id ).correction.days
    end

    temps_reel=
      distance_of_time_in_working_days(temps_ecoule, amplitude)
    temps_prevu_correction=
      distance_of_time_in_working_days(temps_correction, amplitude)
    if temps_reel > temps_prevu_correction
      Time.in_words(temps - temps_correction, self.contrat.interval) <<
        _(' of overrun')
    else
      Time.in_words(temps, self.contrat.interval)
    end
  end

  def interval
    self.contrat.interval
  end

#  private
  def affiche_delai(temps_passe, delai)
    value = calcul_delai(temps_passe, delai)
    return "-" if value == 0
    distance = Time.in_words(value.abs, self.contrat.interval)
    if value >= 0
      "<p style=\"color: green\">#{distance}</p>"
    else
      "<p style=\"color: red\">#{distance}</p>"
    end
  end

  def calcul_delai(temps_passe, delai)
    return 0 if delai == -1
    - (temps_passe - delai * contrat.interval_in_seconds)
  end


  # Calcule en JO (jours ouvrés) le temps écoulé
  def distance_of_time_in_working_days(distance_in_seconds, period_in_hour)
    distance_in_minutes = ((distance_in_seconds.abs)/60.0)
    jo = period_in_hour * 60.0
    distance_in_minutes.to_f / jo.to_f
  end


  protected
  # this method must be protected and cannot be private as Ruby 1.8.6
  def appellee
#     @appellee ||= self.versions.find(:first, :conditions => 'statut_id=2',
#                                     :order => 'updated_on ASC')
    @appellee ||= self.commentaires.find(:first, :conditions => 'statut_id=2',
                                         :order => 'updated_on ASC')
  end


end
