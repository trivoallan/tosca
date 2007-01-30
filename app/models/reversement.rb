#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Reversement < ActiveRecord::Base
  # le :include sert à specifier quel 
  # beneficiaire pourra consulter le reversement
  belongs_to :correctif
  belongs_to :interaction
  belongs_to :etatreversement

  def self.content_columns
    @content_columns ||= columns.reject { |c| c.primary || 
        c.name =~ /(_id|_on)$/ || c.name == inheritance_column }     
  end

  # date de cloture formattée
  # voir lib/overrides.rb pour les dates auto created _on et updated_on
  def cloture_formatted
      d = @attributes['cloture']
      "#{d[8,2]}.#{d[5,2]}.#{d[0,4]} à #{d[11,2]}h#{d[14,2]}"
  end

  # délai (en secondes) entre la déclaration et l'acceptation
  # delai_to_s (texte)
  # en jours : sec2jours(delai)
  def delai
    (cloture - created_on)
  end
  def delai_to_s
    if reverse : "#{time_in_french_words(delai)}"
    elsif clos && !accepte : "Sans objet"
    else "..."
    end 
  end

  # conditions de mise à jour d'un reversement
  # + "non clos" ET (updated_on > 1 mois)
  # + OU "à reverser"
  def todo(max_jours)
    # TODO : vérifier max_jours is integer
    age = ((Time.now - updated_on)/(60*60*24)).round
    if !clos && age > max_jours.to_i
      # non clos && non maj
      return "mettre-à-jour" 
    elsif etatreversement == 0
      # non initialisé
      return "reverser"
    else 
      # rien à faire
      return false
    end
  end

  # bilan du workflow "etatreversement" et du booleen "accepte"
  def etat
    out = etatreversement.nom
    case etatreversement.id
     when 1..3 then out << " "
     when 4    then out << " : <b>#{( accepte ? "accepté" : "refusé" )}</b>"
     else           out << " (?)"
    end
    out
  end

  # retourne true si l'état du reversement est final
  def clos
    etatreversement.id==4 
  end

  # retourne true si le reversement est clos et qu'il a été accepté
  def reverse
    clos && accepte
  end

end
