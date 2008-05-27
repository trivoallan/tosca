class Urlreversement < ActiveRecord::Base
  belongs_to :contribution

  validates_presence_of :valeur
  validates_presence_of :contribution

  def name
    valeur
  end

end
