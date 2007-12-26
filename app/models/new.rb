class New < ActiveRecord::Base
  belongs_to :ingenieur
  belongs_to :client
  belongs_to :logiciel

  def name
    subject
  end
end
