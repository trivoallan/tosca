#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
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
  def self.nb_jours_ouvres(debut, fin)
    debut.inspect
    fin.inspect
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
#     logger.debug('****init : ' + courant.to_s + ' jusqua ' + fin.to_s)
#     while(courant < fin)
#       result += 1 if Jourferie.est_ouvre(courant)
#       courant += 1.day
#       logger.debug('***work : ' + courant.to_s + ' | ' + result.to_s)
#     end
#     logger.debug('***result : ' + courant.to_s + ' | ' + result.to_s)
  end

  private
  # C'est encore trop lent de faire une requête pour tester 
  # chaque jour
  # TODO : faire une requête pour tester l'ensemble
  def self.est_ouvre(date)
    return false if date.wday == 0 || date.wday == 6

    conditions = ['jourferies.jour = ?',date]
    return false if Jourferie.find(:first, :conditions => conditions)
    true
  end

  def self.vendredi_saint
     Date.new(1, 1, 1)
  end

  def self.lundi_de_paques
    Date.new(1, 1, 1)
  end

  def self.ascension
    Date.new(1, 1, 1)
  end

  # http://fr.wikipedia.org/wiki/Jour_f%C3%A9ri%C3%A9
  # L'année ne compte pas, ainsi on la met à 0
  JOUR_FERIE_FRANCE = [ Date.new(0, 1, 1), #1er janvier
                        Jourferie.vendredi_saint,
                        Jourferie.lundi_de_paques,
                        Date.new(0, 5, 1), #1er mai
                        Date.new(0, 5, 8), #8 mai
                        Jourferie.ascension,
                        Date.new(0, 7, 14), #14 juillet
                        Date.new(0, 8, 15), #15 août
                        Date.new(0, 11, 1), #1er novembre
                        Date.new(0, 11, 11), #11 novembre
                        Date.new(0, 12, 25)] #25 décembre





end
