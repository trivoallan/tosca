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
    return debut if Jourferie.est_ouvre(debut)
    debut = debut.change(:hour => 0, :minute => 0, :second => 0)
    while not Jourferie.est_ouvre(debut)
      debut += 1.day
    end
    debut
  end

  #renvoie le dernier jour travaillé
  def self.get_dernier_jour_ouvre(fin)
    return fin if Jourferie.est_ouvre(fin)
    fin = fin.change(:hour => 0, :minute => 0, :second => 0)
    while not Jourferie.est_ouvre(fin)
      fin -= 1.day
    end
    fin
  end


  #A appeler sur 2 dates dont l'heure, les minutes et les seconds sont à 0
  def self.nb_jours_ouvres(debut, fin)
    # 1 jour = 86400 secondes
    result = 0
    while(debut < fin)
      result += 1 if Jourferie.est_ouvre(debut)
      debut += 1.day
    end
    result
  end

  private
  # C'est encore trop lent de faire une requête pour tester 
  # chaque jour
  # TODO : faire une requête pour tester l'ensemble
  def self.est_ouvre(date)
    false if date.wday == 0 || date.wday == 6

    conditions = ['jourferies.jour = ?',date]
    false if Jourferies.find(:first, :conditions => conditions)
    true
  end
end
