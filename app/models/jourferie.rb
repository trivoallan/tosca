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
  # TODO c'est nul
  # Il faut faire une requête sur l'intervalle entre début et fin,
  # et y soustraire les WEs et les jours fériés trouvés
  def self.nb_jours_ouvres(debut, fin)
    # 1 jour = 86400 secondes
    result = 0
    courant = debut.beginning_of_day
    while(courant < fin)
      result += 1 if Jourferie.est_ouvre(courant)
      courant += 1.day
    end
    result
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
