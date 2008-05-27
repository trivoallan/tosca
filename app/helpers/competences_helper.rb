module CompetencesHelper

  def liste_competences(competences)
    competences.collect{|c| c.name}.join(', ')
  end
end
