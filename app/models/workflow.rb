class Workflow < ActiveRecord::Base
  belongs_to :issuetype
  belongs_to :statut

  serialize :allowed_status_ids, Array

  validates_presence_of :statut, :issuetype

  def allowed_status
    Statut.find(self.allowed_status_ids)
  end

  def name
    "<b>#{self.statut.name}</b> => (#{self.allowed_status.join(', ')})"
  end

  include Comparable
  # Used for workflows.sort! call, among other things
  def <=>(other)
    self.statut_id <=> other.statut_id
  end
end
