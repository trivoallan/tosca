#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################

class Demande < ActiveRecord::Base
  belongs_to :typedemande
  belongs_to :logiciel
  belongs_to :severite
  belongs_to :beneficiaire
  belongs_to :statut
  belongs_to :ingenieur
  has_and_belongs_to_many :paquets
  # TODO : à voir si c'est inutile. avec le socle, on a dejà la plateforme
  has_and_belongs_to_many :binaires
  has_many :appels
  has_many :commentaires, :order => "updated_on DESC", :dependent => :destroy
  belongs_to :contribution
  belongs_to :socle
  has_many :piecejointes, :through => :commentaires


  validates_presence_of :resume, 
       :warn => "Vous devez indiquer un résumé de votre demande"
  validates_length_of :resume, :within => 3..60

  #versioning, qui s'occupe de la table demandes_versions
  acts_as_versioned

  # Corrigées, Cloturées et Annulées
  # MLO : on met un '> 6' à la place du 'IN' ?
  TERMINEES = 'demandes.statut_id IN (5,6,7,8)'
  EN_COURS = 'demandes.statut_id NOT IN (5,6,7,8)'

  # WARNING : you cannot use this scope with the optimisation hidden 
  # in the model of Demande. You must then use get_scope_without_include
  def self.set_scope(client_ids)
    scope = { :conditions => [ 'beneficiaires.client_id IN (?)', client_ids],
      :include => [:beneficiaire] } 
    self.scoped_methods << { :find => scope, :count => scope }
  end

  # return the condition of the scope.
  # Used in controller demande for the speed n dirty hack finder
  # on list actions
  def self.get_scope_without_include(client_ids)
    { :find => { :conditions => 
        [ 'beneficiaires.client_id IN (?)', client_ids]} }
  end

  def to_param
    "#{id}-#{resume.gsub(/[^a-z1-9]+/i, '-')}"
  end
  
  def to_s
    "#{typedemande.nom} (#{severite.nom}) : #{description}"
  end

  # We use finder for overused view mainly (demandes/list)
  # It's about 40% faster with this crap (from 2.8 r/s to 4.0 r/s)
  # it's not enough, but a good start :)
  SELECT_LIST = 'demandes.*, severites.nom as severites_nom, ' + 
    'logiciels.nom as logiciels_nom, id_benef.nom as beneficiaires_nom, ' +
    'typedemandes.nom as typedemandes_nom, clients.nom as clients_nom, ' +
    'id_inge.nom as ingenieurs_nom, statuts.nom as statuts_nom '
  JOINS_LIST = 'INNER JOIN severites ON severites.id=demandes.severite_id ' + 
    'INNER JOIN beneficiaires ON beneficiaires.id=demandes.beneficiaire_id '+
    'INNER JOIN identifiants id_benef ON id_benef.id=beneficiaires.identifiant_id '+
    'INNER JOIN clients ON clients.id = beneficiaires.client_id '+
    'LEFT OUTER JOIN ingenieurs ON ingenieurs.id = demandes.ingenieur_id ' + 
    'LEFT OUTER JOIN identifiants id_inge ON id_inge.id=ingenieurs.identifiant_id '+
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
      c.name =~ /(_id|_on|version|resume|description|reproductible)$/ || 
      c.name == inheritance_column } 
  end

  def client
    @client ||= ( beneficiaire ? beneficiaire.client : nil )
    @client
  end

  def reproduit
    if reproductible then 'Oui' else 'Non' end
  end

  def respect_contournement(contrat_id)
    affiche_delai(temps_ecoule, engagement(contrat_id).contournement)
  end

  def respect_correction(contrat_id)
    affiche_delai(temps_ecoule, engagement(contrat_id).correction)
  end

  def affiche_temps_correction
    distance_of_time_in_french_words(self.temps_correction, client.support)
  end

  def temps_correction
    result = 0
    corrigee = self.versions.find(:first, :conditions => 'statut_id IN (6,7)',
                                  :order => 'updated_on ASC')
    if corrigee and self.appellee()
      result = compute_temps_ecoule(corrigee.statut_id) 
    end
    result
  end

  # Retourne le délais imparti pour corriger la demande
  # TODO : validation MLO
  # TODO : inaffichable dans la liste des demandes > améliorer le calcul de ce délais
  def delais_correction
    delais = paquets.compact.collect{|p|
     p.correction(typedemande_id, severite_id) * 
      p.contrat.client.support.interval_in_seconds 
   }.min
  end

  def affiche_temps_contournement
    distance_of_time_in_french_words(self.temps_contournement, client.support)
  end

  def temps_contournement
    result = 0
    contournee = self.versions.find(:first, :conditions => 'statut_id=5', 
                                    :order => 'updated_on ASC')
    if contournee and self.appellee()
      result = compute_temps_ecoule(5)
    end
    result
  end

  def affiche_temps_rappel
    self.distance_of_time_in_french_words(self.temps_rappel, client.support)
  end

  def temps_rappel
    result = 0
    first = self.versions[0]
    if (self.versions.size > 2) and (first.statut_id == 1) and self.appellee()
      result = compute_diff(first.updated_on, appellee().updated_on, 
                            client.support) 
    end
    result
  end

  def engagement(contrat_id)
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
  def affiche_temps_ecoule
    temps = temps_ecoule
    return "sans engagement" if temps == -1 
    distance_of_time_in_french_words(temps, client.support)
  end

#  private
  def affiche_delai(temps_passe, delai)
    value = calcul_delai(temps_passe, delai)
    return "N/A" if value == 0
    distance = distance_of_time_in_french_words(value.abs, client.support)
    if value >= 0
      "<p style=\"color: green\">#{distance}</p>"
    else
      "<p style=\"color: red\">#{distance}</p>"
    end
  end

  def calcul_delai(temps_passe, delai)
    return 0 if delai == -1
    - (temps_passe - delai * client.support.interval_in_seconds)
  end

  def compute_temps_ecoule(to = nil)
    return 0 unless self.versions.size > 0
    support = client.support
    changes = self.versions # Demandechange.find(:all)
    statuts_sans_chrono = [ 3, 7, 8 ] #Suspendue, Cloture, Annulée, cf modele statut
    inf = { :date => self.created_on, :statut => changes.first.statut_id } #1er statut : enregistré !
    delai = 0
    for c in changes
      sup = { :date => c.updated_on, :statut => c.statut_id }
      unless statuts_sans_chrono.include? inf[:statut]
        delai += compute_diff(Jourferie.get_premier_jour_ouvre(inf[:date]),
                              Jourferie.get_dernier_jour_ouvre(sup[:date]),
                              support)
      end
      inf = sup
      break if to == inf[:statut]
    end

    unless statuts_sans_chrono.include? self.statut.id and to != nil
      sup = { :date => Time.now, :statut => self.statut_id }
      delai += compute_diff(Jourferie.get_premier_jour_ouvre(inf[:date]), 
                            Jourferie.get_dernier_jour_ouvre(sup[:date]), 
                            support)
    end
    delai
  end

  ##
  # Calcule le différentiel en secondes entre 2 jours,
  # selon les horaires d'ouverture du 'support' et les jours fériés
  def compute_diff(dateinf, datesup, support)
    return 0 unless support
    borneinf = dateinf.beginning_of_day
    bornesup = datesup.beginning_of_day
    nb_jours = Jourferie.nb_jours_ouvres(borneinf, bornesup)
    result = 0
    if nb_jours == 0
      return compute_diff_day(dateinf, datesup, support)
#       borneinf = dateinf
#       bornesup = datesup.change(:mday => dateinf.day,
#                                 :month => dateinf.month,
#                                 :year => dateinf.year)
    else
      result = ((nb_jours-1) * support.interval_in_seconds) 
    end
    borneinf = borneinf.change(:hour => support.fermeture)
    bornesup = bornesup.change(:hour => support.ouverture)

    # La durée d'un jour ouvré dépend des horaires d'ouverture
    result += compute_diff_day(dateinf, borneinf, support)
#     puts 'dateinf ' + dateinf.to_s + ' borneinf ' + borneinf.to_s + ' result 1 : ' + compute_diff_day(dateinf, borneinf, support).to_s
    result += compute_diff_day(bornesup, datesup, support)
#     puts 'bornesup ' + bornesup.to_s + ' datesup ' + datesup .to_s + ' result 2 : ' +  compute_diff_day(bornesup, datesup, support).to_s
    result
  end

  ##
  # Calcule le temps en seconde qui est écoulé durant la même journée
  # En temps ouvré, selon les horaires du 'support'
  def compute_diff_day(jourinf, joursup, support)
    # mise au minimum à 7h
    borneinf = jourinf.change(:hour => support.ouverture)
    jourinf = borneinf if jourinf < borneinf
    # mise au minimum à 19h
    bornesup = joursup.change(:hour => support.fermeture)
    joursup = bornesup if joursup > bornesup
    #on reste dans les bornes
    return 0 unless jourinf < joursup
    (joursup - jourinf)
  end

  # FONCTION vers lib/lstm.rb:time_in_french_words
  def distance_of_time_in_french_words(distance_in_seconds, support)
    dayly_time = support.fermeture - support.ouverture # in hours
    Lstm.time_in_french_words(distance_in_seconds, dayly_time)
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
    @appellee ||= self.versions.find(:first, :conditions => 'statut_id=2', 
                                    :order => 'updated_on ASC')
  end


end
