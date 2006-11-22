#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Demande < ActiveRecord::Base
  belongs_to :typedemande
  belongs_to :logiciel
  belongs_to :severite
  belongs_to :beneficiaire
  belongs_to :socle
  belongs_to :statut
  belongs_to :ingenieur
  has_and_belongs_to_many :paquets
  has_many :commentaires, :order => "updated_on DESC", :dependent => :destroy
  has_many :demandechanges, :dependent => :destroy
  belongs_to :correctif

  #versioning, qui s'occupe de la table demandes_versions
  acts_as_versioned

  has_many :piecejointes, :through => :commentaires
  validates_presence_of :resume, 
  :warn => "Vous devez indiquer un résumé de votre demande"
  validates_length_of :resume, :within => 3..60

  def to_param
    "#{id}-#{resume.gsub(/[^a-z1-9]+/i, '-')}"
  end

  def self.content_columns 
    @content_columns ||= columns.reject { |c| c.primary || 
        c.name =~ /(_id|_on|version|resume|description|reproductible)$/ || c.name == inheritance_column } 
  end

  def client
    @demande_client ||= beneficiaire.client
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
    temps==-1 ? "sans engagement" :
      distance_of_time_in_french_words(temps, client.support)
  end


  private
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
    support = client.support
    changes = Demandechange.find_all_by_demande_id(self.id, :order => "created_on")
    statuts_sans_chrono = [ 3, 7, 8 ] #Suspendue, Cloture, Annulée, cf modele statut
    inf = { :date => self.created_on, :statut => Statut.find(1) } #1er statut : enregistré !
    delai = 0
    for c in changes
      sup = { :date => c.created_on, :statut => c.statut }
#      delai += (sup[:date] - inf[:date]).to_s + " de " + inf[:statut].nom + " à " + sup[:statut].nom + "<br />"
      if not statuts_sans_chrono.include? sup[:statut].id
        delai += compute_diff(Jourferie.get_premier_jour_ouvre(inf[:date]), 
                              Jourferie.get_dernier_jour_ouvre(sup[:date]), 
                              support)
        #delai += " de " + inf[:statut].nom + " à " + sup[:statut].nom + "<br />"
        #delai += " de " + inf[:date].to_s + " à " + sup[:date].to_s + "<br />"
        #delai += "<hr />"
      end
      inf = sup
    end

    if not statuts_sans_chrono.include? self.statut.id
      sup = { :date => Time.now, :statut => self.statut }
      delai += compute_diff(Jourferie.get_premier_jour_ouvre(inf[:date]), 
                            Jourferie.get_dernier_jour_ouvre(sup[:date]), 
                            support)
      #delai += " de " + inf[:statut].nom + " à " + self.statut.nom + "<br />"      
      #delai += " de " + inf[:date].to_s + " à " + sup[:date].to_s + "<br />"      
      #delai += "<hr />"
    end
    delai
  end


 
  def compute_diff(dateinf, datesup, support)
    return 0 unless support
    borneinf = dateinf.change(:hour => 0, :minute => 0, :second => 0)
    bornesup = datesup.change(:hour => 0, :minute => 0, :second => 0)
    nb_jours = Jourferie.nb_jours_ouvres(borneinf, bornesup)
#    return nb_jours.to_s + "<br /> BI " + borneinf.to_s + "<br />" + " BS " + bornesup.to_s + "<br /> "
    return compute_diff_day(dateinf, 
                            datesup.change(:day => dateinf.day,:month => dateinf.month, :year => dateinf.year), 
                            support) if nb_jours == 0
    borneinf = borneinf.change(:hour => support.fermeture)
    bornesup = bornesup.change(:hour => support.ouverture)
    nb_jours -= 1 
    #La durée d'un jour ouvré dépend des horaires d'ouverture
    result = (nb_jours * support.interval_in_seconds) 
    result += compute_diff_day(dateinf, borneinf, support)
    result += compute_diff_day(bornesup, datesup, support)
#    result += " DI " + dateinf.to_s + "<br /> BI " + borneinf.to_s + "<br />"
#    result += " BS " + bornesup.to_s + "<br /> DS " + datesup.to_s + " <br />"
    result
  end

  def compute_diff_day(jourinf, joursup, support)
    #on recup les bornes selon le niveau de support
    borneinf = jourinf.change(:hour => support.ouverture)
    bornesup = joursup.change(:hour => support.fermeture)
    #on reste dans les bornes
    jourinf = borneinf if jourinf < borneinf
    joursup = bornesup if joursup > bornesup
    return 0 unless jourinf < joursup
    (joursup - jourinf)
  end

  # Reports the approximate distance in time between two Time objects or integers. 
  # For example, if the distance is 47 minutes, it'll return
  # "about 1 hour". See the source for the complete wording list.
  #
  # Integers are interpreted as seconds. So,
  # <tt>distance_of_time_in_words(50)</tt> returns "less than a minute".
  #
  # Set <tt>include_seconds</tt> to true if you want more detailed approximations if distance < 1 minute
  
  # J'ai juste traduis les mots, la fonction est nickel :)
  def distance_of_time_in_french_words(distance_in_seconds, support)
    distance_in_minutes = ( distance_in_seconds.abs / 60 ).round()
    jo = (support.fermeture - support.ouverture) * 60
    demi_jo_inf = (jo / 2) - 60
    demi_jo_sup = (jo / 2) + 60

    case distance_in_minutes
    when 0..1 then 
      (distance_in_minutes==0) ? "moins d'une minute" : '1 minute'
    when 2..45      then 
      "#{distance_in_minutes} minutes"
    when 46..90     then 
      'environ 1 heure'
    when 90..demi_jo_inf, (demi_jo_sup+1)..jo   then 
      "environ #{(distance_in_minutes.to_f / 60.0).round} heures"
    when (demi_jo_inf+1)..demi_jo_sup
      "1 demi-jour ouvré"
    when jo..(1.5*jo)
       "1 jour ouvré"
    # à partir de 1.5 inclus, le round fait 2 ou plus : pluriel
    else                 
      "#{(distance_in_minutes / jo).round} jours ouvrés"
    end
  end


end
