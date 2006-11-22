class Jourferie < ActiveRecord::Base


  #TODO : implémenter
  def self.get_premier_jour_ouvre(debut)
    return debut if Jourferie.est_ouvre(debut)
    debut = debut.change(:hour => 0, :minute => 0, :second => 0)
    while not Jourferie.est_ouvre(debut)
      debut += 1.day
    end
    debut
  end

  #TODO : implémenter
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
    while (debut < fin)
      result += 1 if Jourferie.est_ouvre(debut)
      debut += 1.day
    end
    result
  end

  private
  def self.est_ouvre(date)
    #TODO : C'est moche _et_ inefficace, y a surement mieux
    jourferies = []
    for jourferie in Jourferie.find_all
      jourferies += [ jourferie.jour ]
    end
    false if jourferies.include? (date) 
    false if date.wday == 0 || date.wday == 6
    true
  end
end
