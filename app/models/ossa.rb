class Ossa < ActiveRecord::Base
  has_one :contrat, :as => :rule

  def short_description
    if max == -1
      _('Illimited offer on all components')
    else
      _('Illimited offer on a maximum of %d components') % max
    end
  end
end
