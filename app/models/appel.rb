class Appel < ActiveRecord::Base
  belongs_to :ingenieur
  belongs_to :beneficiaire
  belongs_to :demande
  belongs_to :contrat

  validate do |record|
    if record.fin < record.debut
      record.errors.add 'Le début de l\'appel doit être inférieure à sa fin. Il ' 
    end
  end

  validates_presence_of :ingenieur
  validates_presence_of :contrat
  

  def self.set_scope(contrat_ids)
    if contrat_ids
      self.scoped_methods << { :find => { :conditions => 
          [ 'appels.contrat_id IN (?)', contrat_ids ] } }
    end
  end


  # date de reversement formattée
  # voir lib/overrides.rb pour les dates auto created _on et updated_on
  def fin_formatted
      d = @attributes['fin']
      "#{d[8,2]}.#{d[5,2]}.#{d[0,4]} à #{d[11,2]}h#{d[14,2]}"
  end

  # date de reversement formattée
  # voir lib/overrides.rb pour les dates auto created _on et updated_on
  def debut_formatted
      d = @attributes['debut']
      "#{d[8,2]}.#{d[5,2]}.#{d[0,4]} à #{d[11,2]}h#{d[14,2]}"
  end

  def duree
    fin - debut
  end

end
