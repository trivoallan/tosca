class Knowledge < ActiveRecord::Base
  belongs_to :ingenieur
  belongs_to :competence
  belongs_to :logiciel

  validates_presence_of :ingenieur_id
  validate do |record|
    # length consistency
    if record.competence && record.logiciel
      record.errors.add_to_base _('You have to specify a software or a domain.')
    end
    if !record.competence && !record.logiciel
      record.errors.add_to_base _('You cannot specify a software and a domain.')
    end
  end
  # TODO : seach name of the levels ?
  # maybe a new Model ?
  validates_numericality_of :level, :integer => true,
    :greater_than => 0, :lesser_than => 6

  def name
    ( competence_id && competence_id != 0 ? competence.name : logiciel.name )
  end

end
