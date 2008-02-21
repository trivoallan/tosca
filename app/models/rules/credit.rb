#########################################
# The Rules' classes MUST stay coherent #
#########################################
class Rules::Credit < ActiveRecord::Base
  has_one :contrat, :as => :rule

  def elapsed_on_create
    1
  end

  def formatted_elapsed(value)
    n_('%d ticket spent', '%d tickets spent', value) % value
  end

  # It's called like this :
  # rule.compute_elapsed_between(last_status_comment, self)
  # It won't do anything : the credit spent is filled manually, not computed
  def compute_elapsed_between(last, current)
    current.elapsed
  end

  def short_description
    if max == -1
      _('Illimited number of tickets of %s') %
        Time.in_words(time.hours)
    else
      _('Up to %d tickets of %s') %
        [ max, Time.in_words(time.hours) ]
    end
  end

end
