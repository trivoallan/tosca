class Commitment < ActiveRecord::Base
  belongs_to :severite
  belongs_to :typedemande
  has_and_belongs_to_many :contracts, :uniq => true

  validates_each :correction, :workaround do |record, attr, value|
    record.errors.add attr, 'must be >= 0.' if value < 0 and value != -1
  end

  # Our agreement for 0 SLA is '-1' in the database.
  # But the user does not need to learn this.
  def correction=(value)
    value = value.to_f
    write_attribute(:correction, (value == 0.0 ? -1 : value))
  end
  def workaround=(value)
    value = value.to_f
    write_attribute(:workaround, (value == 0.0 ? -1 : value))
  end

  def to_s
    "#{self.typedemande.name} | #{self.severite.name} : " +
      "#{Time.in_words(self.workaround.days, true)} " +
      "/ #{Time.in_words(self.correction.days, true)}"
  end

  INCLUDE = [:typedemande,:severite]
  ORDER = 'commitments.typedemande_id, commitments.severite_id DESC, commitments.workaround DESC'
  OPTIONS = { :include => INCLUDE, :order => ORDER }

end
