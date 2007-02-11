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
end
