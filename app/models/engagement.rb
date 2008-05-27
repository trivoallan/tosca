class Engagement < ActiveRecord::Base
  belongs_to :severite
  belongs_to :typedemande
  has_and_belongs_to_many :contrats

  validates_each :correction, :contournement do |record, attr, value|
    record.errors.add attr, 'must be >= 0.' if value < 0 and value != -1
  end

  # Our agreement for 0 SLA is '-1' in the database.
  # But the user does not need to learn this.
  def correction=(value)
    value = value.to_f
    write_attribute(:correction, (value == 0.0 ? -1 : value))
  end
  def contournement=(value)
    value = value.to_f
    write_attribute(:contournement, (value == 0.0 ? -1 : value))
  end

  def to_s
    "#{self.typedemande.name} | #{self.severite.name} : " +
      "#{Time.in_words(self.contournement.days, true)} " +
      "/ #{Time.in_words(self.correction.days, true)}"
  end

  INCLUDE = [:typedemande,:severite]
  ORDER = 'engagements.typedemande_id, engagements.severite_id DESC, engagements.contournement DESC'
  OPTIONS = { :include => INCLUDE, :order => ORDER }

end
