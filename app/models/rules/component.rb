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
    todo()
  end

  def short_description
    if max == -1
      _('Illimited offer on all components')
    else
      _('Illimited offer on a maximum of %d components') % max
    end
  end

end
