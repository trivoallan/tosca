class TimeTicket < ActiveRecord::Base
  has_one :contrat, :as => :rule

  def short_description
    if max == -1
      _('Illimited number of tickets of %s') %
        Lstm.time_in_french_words(time.hours)
    else
      _('Up to %d tickets of %s') %
        [ max, Lstm.time_in_french_words(hours) ]
    end
  end

end
