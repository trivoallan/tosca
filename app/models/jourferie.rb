#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
# Why do we have a special table for holidays ?
# It's because some of them can be so arbitrary.
# So we can have a quick way of adding and keeping
# an arbitrary holiday. Maybe there is a better way.
class Jourferie < ActiveRecord::Base
  def jour_formatted
    d = @attributes['jour']
    "#{d[8,2]}.#{d[5,2]}.#{d[0,4]}"
  end


  #renvoie le premier jour travaillé
  def self.get_premier_jour_ouvre(debut)
    courant = debut.beginning_of_day
    return debut if Jourferie.est_ouvre(courant)
    courant += 1.day
    while not Jourferie.est_ouvre(courant)
      courant += 1.day
    end
    courant
  end

  #renvoie le dernier jour travaillé
  def self.get_dernier_jour_ouvre(fin)
    courant = fin.beginning_of_day
    return fin if Jourferie.est_ouvre(courant)
    courant -= 1.day
    while not Jourferie.est_ouvre(courant)
      courant -= 1.day
    end
    courant
  end


  #A appeler sur 2 dates dont l'heure, les minutes et les seconds sont à 0
  # TODO : y intégrer la constante JOUR_FERIE_FRANCE
  def self.nb_jours_ouvres(debut, fin)
    return 0 if fin < debut
    result = 0
    starting = debut
    ending = fin

    # logger.debug('****init : ' + starting.to_s + ' jusqua ' + ending.to_s)
    result = ((ending - starting) / 1.day).round
    # logger.debug('**** base : ' + result.to_s)
    return result unless (result > 7) or (starting.wday > ending.wday)
    # on y soustrait les WE
    result -= ((result / 7.0).floor*2)
    # sans oublier le dernier we
    result -= 2 if (starting.wday > ending.wday)
    # logger.debug('**** result / 7 : ' + result.to_s)
    # ni les joursfériés de l'intervalle
    conditions = ['jourferies.jour BETWEEN ? AND ?', starting, ending ]
    result -=  Jourferie.count(:all, :conditions => conditions)
    # logger.debug('**** result : ' + result.to_s)
    result
#   ancienne version : lente mais garantie
#     courant = debut.beginning_of_day
#     while(courant < fin)
#       result += 1 if Jourferie.est_ouvre(courant)
#       courant += 1
#     end
    result
  end

  private
  # C'est encore trop lent de faire une requête pour tester
  # chaque jour
  # TODO : faire une requête pour tester l'ensemble
  def self.est_ouvre(date)
    return false if date.wday == 0 || date.wday == 6
    return false if JOUR_FERIE_FRANCE.include?(date)
    conditions = ['jourferies.jour = ?',date]
    return false if Jourferie.find(:first, :conditions => conditions)
    true
  end

  # TODO : Un jour penser à faire que l'on ai pas besoin de redémarrer le serveur une fois l'an ...
  ANNEE_ACTUELLE = Time.now.year

  def self.paques
    @@temps_passe ||= Jourferie.calcul_paques
    @@temps_passe
  end

  # Calcul : http://fr.wikipedia.org/wiki/Calcul_de_la_date_de_P%C3%A2ques
  # On prend cette version : http://fr.wikipedia.org/wiki/Calcul_de_la_date_de_P%C3%A2ques#Algorithme_de_Thomas_O.E2.80.99Beirne
  # Le résultat n'est valide que si la période est entre 1900 et 2099 (on a le temps de voir venir)
  def self.calcul_paques
    n = ANNEE_ACTUELLE - 1900
    a = n % 19
    b = (a * 7 +1) / 19
    c = ((11 * a) - b + 4) % 29
    d = n / 4
    e = (n - c + d +31) % 7
    p = 25 - c - e
    trente_et_un_mars = Date.new(ANNEE_ACTUELLE, 3, 31)
    trente_et_un_mars + p
  end

  # 1 jour après paques
  def self.lundi_de_paques
    Jourferie.paques + 1
  end

  # 40 jours après paques
  def self.ascension
     Jourferie.paques + 40
  end

  # http://fr.wikipedia.org/wiki/Jour_f%C3%A9ri%C3%A9
  JOUR_FERIE_FRANCE = [ Date.new(ANNEE_ACTUELLE, 1, 1), #1er janvier
                        Jourferie.lundi_de_paques,
                        Date.new(ANNEE_ACTUELLE, 5, 1), #1er mai
                        Date.new(ANNEE_ACTUELLE, 5, 8), #8 mai
                        Jourferie.ascension,
                        Date.new(ANNEE_ACTUELLE, 7, 14), #14 juillet
                        Date.new(ANNEE_ACTUELLE, 8, 15), #15 août
                        Date.new(ANNEE_ACTUELLE, 11, 1), #1er novembre
                        Date.new(ANNEE_ACTUELLE, 11, 11), #11 novembre
                        Date.new(ANNEE_ACTUELLE, 12, 25)] #25 décembre

end
