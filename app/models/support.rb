class Support < ActiveRecord::Base
  def interval_in_seconds
    return (fermeture - ouverture) * 1.hour
  end
end

