class Etatreversement < ActiveRecord::Base
  acts_as_reportable
  has_many :contributions
end
