class TimeTicket < ActiveRecord::Base
  has_one :contrat, :as => :rule

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
