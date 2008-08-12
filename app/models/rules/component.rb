#########################################
# The Rules' classes MUST stay coherent #
#########################################
class Rules::Component < ActiveRecord::Base

  def elapsed_on_create
    0
  end

  def elapsed_formatted(value, contract)
    Time.in_words(value, contract.interval)
  end

  # Call it like this :
  # rule.compute_between(last_status_comment, self, contract)
  # It will update "self.elapsed" with the elapsed time between
  # the 2 comments which MUST change the status
  def compute_between(last, current, contract)
    return 0 unless last.statut_id != 0 && current.statut_id != 0
    return 0 unless Statut::Running.include? last.statut_id
    Time.working_diff(last.created_on, current.created_on,
                      contract.opening_time,
                      contract.closing_time)
  end

  def short_description
    if max == -1
      _('Illimited offer on all components')
    else
      _('Illimited offer on a maximum of %d components') % max
    end
  end

end
