class Preferences < ActiveRecord::Base
  belongs_to :identifiant, :dependent => :destroy

end
