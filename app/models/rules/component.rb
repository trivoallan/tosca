class Rules::Component < ActiveRecord::Base
  has_one :contrat, :as => :rule

  def elapsed_on_create
    0
  end

  def formatted_elapsed(value)
    Time.in_words(value)
  end

  def short_description
    if max == -1
      _('Illimited offer on all components')
    else
      _('Illimited offer on a maximum of %d components') % max
    end
  end

end
