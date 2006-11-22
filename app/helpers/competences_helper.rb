module CompetencesHelper

  def liste_competences(competences)
    competences.collect{|c| c.nom}.join(', ')
  end
end
