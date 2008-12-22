class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :model, :polymorphic => true

  validates_presence_of :user, :model

  
end
