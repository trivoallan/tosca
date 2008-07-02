class Version < ActiveRecord::Base
  belongs_to :logiciel
  has_many :releases, :dependent => :destroy
  has_and_belongs_to_many :contributions
end
