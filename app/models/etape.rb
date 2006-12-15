class Etape < ActiveRecord::Base
  def to_s
    nom
  end
end
