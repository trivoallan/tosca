class Competence < ActiveRecord::Base
  has_many :knowledges
  has_many :ingenieurs, :through => :knowledges
end
