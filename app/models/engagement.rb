#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Engagement < ActiveRecord::Base
  belongs_to :severite
  belongs_to :typedemande
  has_and_belongs_to_many :contrats

  def contourne(delai)
    compute(delai, contournement)
  end

  def corrige(delai)
    compute(delai, correction)
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

  def to_s
    "#{self.typedemande.nom} | #{self.severite.nom} : " + 
      "#{Lstm.time_in_french_words(self.contournement.days, true)} " + 
      "/ #{Lstm.time_in_french_words(self.correction.days, true)}"
  end

  #affiche le nombre de jours ou un "sans engagement"
  # voir application_helper
  #
  #def display_jours(temps)
  #  return temps unless temps.is_a? Numeric
  #  case temps
  #    when -1 then "sans engagement" 
  #    when 1 then "1 jour ouvré"
  #    else temps.to_s + " jours ouvrés"
  #  end
  #end

end
