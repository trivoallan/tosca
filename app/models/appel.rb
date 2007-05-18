# This class represent a phone Call for a Request from a Recipient to 
# an Engineer. There's also a link to the contract, because those phones
# calls can be in the 24/24 contract.
class Appel < ActiveRecord::Base
  belongs_to :ingenieur
  belongs_to :beneficiaire
  belongs_to :demande
  belongs_to :contrat

  validate do |record|
    if record.fin < record.debut
      record.errors.add _('Le début de l\'appel doit être inférieure à sa fin.')
    end
  end

  validates_presence_of :ingenieur
  validates_presence_of :contrat
  
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
  def fin_formatted
      d = @attributes['fin']
      "#{d[8,2]}.#{d[5,2]}.#{d[0,4]} à #{d[11,2]}h#{d[14,2]}"
  end

  # start of the phone call, formatted without the need to load Time.
  # See ActiveRecord::Base for more information
  def debut_formatted
      d = @attributes['debut']
      "#{d[8,2]}.#{d[5,2]}.#{d[0,4]} à #{d[11,2]}h#{d[14,2]}"
  end

  def duree
    fin - debut
  end

end
