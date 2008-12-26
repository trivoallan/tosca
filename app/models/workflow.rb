class Workflow < ActiveRecord::Base
  belongs_to :issuetype
  belongs_to :statut

  serialize :allowed_status_ids, Array

  validates_presence_of :statut, :issuetype

  def allowed_status
    Statut.find(self.allowed_status_ids)
  end
end
