#########################################
# The Rules' classes MUST stay coherent #
#########################################
class Rules::Component < ActiveRecord::Base
  has_one :contrat, :as => :rule

  def elapsed_on_create
    0
  end

  def formatted_elapsed(value)
    Time.in_words(value)
  end

  # Call it like this :
  # rule.compute_elapsed_between(last_status_comment, self)
  # It will update "self.elapsed" with the elapsed time between
  # the 2 comments which MUST change the status
  def compute_elapsed_between(last, current)
    return 0 unless last.statut_id != 0 && current.statut_id != 0
    return 0 if Statut::WithoutChrono.include? last.statut_id
    Time.working_diff(last.created_on, current.created_on,
                      contrat.heure_ouverture,
                      contrat.heure_fermeture)
  end

  def short_description
    if max == -1
      _('Illimited offer on all components')
    else
      _('Illimited offer on a maximum of %d components') % max
    end
  end

end
