class Release < ActiveRecord::Base
  belongs_to :version
  belongs_to :contract
  
  has_many :changelogs
  
  
end
