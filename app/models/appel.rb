class Appel < ActiveRecord::Base
  belongs_to :ingenieur
  has_one :beneficiaire
  has_and_belongs_to_many :demandes
  belongs_to :contrat

  validate do |record|
    if record.fin < record.debut
      record.errors.add 'Le début de l\'appel doit être inférieure à sa fin' 
    end
  end


  # date de reversement formattée
  # voir lib/overrides.rb pour les dates auto created _on et updated_on
  def fin_formatted
      d = @attributes['debut']
      "#{d[8,2]}.#{d[5,2]}.#{d[0,4]} à #{d[11,2]}h#{d[14,2]}"
  end

  # date de reversement formattée
  # voir lib/overrides.rb pour les dates auto created _on et updated_on
  def debut_formatted
      d = @attributes['fin']
      "#{d[8,2]}.#{d[5,2]}.#{d[0,4]} à #{d[11,2]}h#{d[14,2]}"
  end

  def duree
    fin - debut
  end


end
