# This class represent a phone Call for a Request from a Recipient to
# an Engineer. There's also a link to the contract, because those phones
# calls can be in the 24/24 contract.
class Phonecall < ActiveRecord::Base
  acts_as_reportable
  belongs_to :ingenieur
  belongs_to :beneficiaire
  belongs_to :demande
  belongs_to :contrat

  validate do |record|
    if record.end < record.start
      record.errors.add _('The beginning of the call has to be before to its end.')
    end
  end
  validates_presence_of :ingenieur
  validates_presence_of :contrat
  validate do |record|
    if record.beneficiaire and
      record.beneficiaire.client_id != record.contrat.client_id
      record.errors.add _('recipient and client have to correspond.')
    end
  end

  # This reduced the scope of Calls to contract_ids in parameters.
  # With this, every Recipient only see what he is concerned of
  def self.set_scope(contrat_ids)
    if contrat_ids
      self.scoped_methods << { :find => { :conditions =>
          [ 'appels.contrat_id IN (?)', contrat_ids ] } }
    end
  end

  # end of the phone call, formatted without the need to load Time.
  # See ActiveRecord::Base for more information
  def end_formatted
    d = @attributes['end']
    _("%s.%s.%s at %sh%s") % [ d[8,2], d[5,2], d[0,4], d[11,2], d[14,2] ]
  end

  # start of the phone call, formatted without the need to load Time.
  # See ActiveRecord::Base for more information
  def start_formatted
    d = @attributes['start']
    _("%s.%s.%s at %sh%s") % [ d[8,2], d[5,2], d[0,4], d[11,2], d[14,2] ]
  end

  def length
    # end is a reserved word for ruby ...
  self.end - self.start
  end

  # For Ruport :
  def contrat_name
    contrat.name
  end
  def ingenieur_name
    ingenieur.name
  end
  def beneficiaire_name
    beneficiaire ? beneficiaire.name : '-'
  end

end
