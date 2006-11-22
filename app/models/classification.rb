
class Classification < ActiveRecord::Base
  belongs_to :logiciel
  belongs_to :groupe
  belongs_to :bouquet
  belongs_to :client
end
