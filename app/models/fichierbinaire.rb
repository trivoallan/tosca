class Fichierbinaire < ActiveRecord::Base
  belongs_to :binaire, :counter_cache => true
end
