#########################################
# The Rules' classes MUST stay coherent #
#########################################
class Rules::Credit < ActiveRecord::Base

  def elapsed_on_create
    1
  end

  def elapsed_formatted(value, contract)
    n_('%d time-credit', '%d time-credits', value) % value
  end

  # It's called like this :
  # rule.compute_elapsed_between(last_status_comment, self)
  # It won't do anything : the credit spent is filled manually, not computed
  def compute_between(last, current, contract)
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
