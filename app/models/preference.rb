class Preference < ActiveRecord::Base
  belongs_to :identifiant, :dependent => :destroy

end
