class Url < ActiveRecord::Base

  belongs_to :resource, :polymorphic => true

  validates_presence_of :value
  belongs_to :typeurl

  def nom
    value
  end

  def to_s
    nom
  end

end
