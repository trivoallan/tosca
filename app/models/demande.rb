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
        c.name =~ /(_id|_on|version|resume|description|reproductible)$/ || c.name == inheritance_column } 
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
    corrigee = self.versions.find(:first, :conditions => 'statut_id=6', :order => 'updated_on ASC')
    if corrigee
      appellee = self.versions.find(:first, :conditions => 'statut_id=2', :order => 'updated_on ASC')
      if appellee
        result = compute_diff(appellee.updated_on, corrigee.updated_on, client.support)
      end
    end
    result
  end

  # Retourne le délais imparti pour corriger la demande
  # TODO : validation MLO
  # TODO : inaffichable dans la liste des demandes > améliorer le calcul de ce délais
  def delais_correction
    delais = paquets.compact.collect{|p|
     p.correction(typedemande_id, severite_id) * p.contrat.client.support.interval_in_seconds 
   }.min
  end

  def affiche_temps_contournement
    distance_of_time_in_french_words(self.temps_contournement, client.support)
  end

  def temps_contournement
    result = 0
    contournee = self.versions.find(:first, :conditions => 'statut_id=5', :order => 'updated_on ASC')
    if contournee
      appellee = self.versions.find(:first, :conditions => 'statut_id=2', :order => 'updated_on ASC')
      if appellee
        result = compute_diff(appellee.updated_on, contournee.updated_on, client.support)
      end
    end
    result
  end

  def affiche_temps_rappel
    distance_of_time_in_french_words(self.temps_rappel, client.support)
  end

  def temps_rappel
    result = 0
    first = self.versions[0]
    if (self.versions.size > 2) and (first.statut_id == 1)
      appellee = self.versions.find(:first, :conditions => 'statut_id=2', :order => 'updated_on ASC')
      result = compute_diff(first.updated_on, appellee.updated_on, client.support) if appellee
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

  def compute_temps_ecoule
#     return (self.updated_on - self.created_on).to_i
    return 0 unless self.versions.size > 0
    support = client.support
    changes = self.versions # Demandechange.find(:all)
    statuts_sans_chrono = [ 3, 7, 8 ] #Suspendue, Cloture, Annulée, cf modele statut
    inf = { :date => self.created_on, :statut => changes.first.statut_id } #1er statut : enregistré !
    delai = 0
    for c in changes
      sup = { :date => c.updated_on, :statut => c.statut_id }
#      delai += (sup[:date] - inf[:date]).to_s + " de " + inf[:statut].nom + " à " + sup[:statut].nom + "<br />"
      unless statuts_sans_chrono.include? inf[:statut]
        delai += compute_diff(Jourferie.get_premier_jour_ouvre(inf[:date]),
                              Jourferie.get_dernier_jour_ouvre(sup[:date]),
                              support)
#         puts 'debut ' + Jourferie.get_premier_jour_ouvre(inf[:date]).to_s
#         puts 'fin ' + Jourferie.get_dernier_jour_ouvre(sup[:date]).to_s
#         puts 'delai ' + compute_diff(Jourferie.get_premier_jour_ouvre(inf[:date]),
#                               Jourferie.get_dernier_jour_ouvre(sup[:date]),
#                               support).to_s
#           delai += sup[:date] - inf[:date]
      end
      inf = sup
    end

    unless statuts_sans_chrono.include? self.statut.id
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

end
