#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Engagement < ActiveRecord::Base
  belongs_to :severite
  belongs_to :typedemande
  has_and_belongs_to_many :contrats

  validates_each :correction, :contournement do |record, attr, value|
    record.errors.add attr, 'must be >= 0.' if value < 0 and value != -1
  end

  # No agreement is '-1' in the database.
  # But the user does not need to learn this.
  def correction=(value)
    value = value.to_f
    write_attribute(:correction, (value == 0.0 ? -1 : value))
  end
  def contournement=(value)
    value = value.to_f
    write_attribute(:contournement, (value == 0.0 ? -1 : value))
  end

  def contourne(delai)
    compute(delai, contournement)
  end

  def corrige(delai)
    compute(delai, correction)
  end

  def to_s
    "#{self.typedemande.name} | #{self.severite.name} : " +
      "#{Lstm.time_in_french_words(self.contournement.days, true)} " +
      "/ #{Lstm.time_in_french_words(self.correction.days, true)}"
  end

  private
  # note : -1 == Date infinie !
  def compute(delai, limite)
    raise "Erreur dans le calcul du delai " unless delai.kind_of? Numeric
    (limite == -1 ? true : (delai < limite*3600))
  end

  INCLUDE = [:typedemande,:severite]
  ORDER = 'engagements.typedemande_id, engagements.severite_id DESC, engagements.contournement DESC'
  OPTIONS = { :include => INCLUDE, :order => ORDER }

end
