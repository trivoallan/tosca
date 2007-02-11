#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Correctif < ActiveRecord::Base
  has_many :demandes
  has_many :urlreversements

  belongs_to :typecontribution
  belongs_to :etatreversement
  belongs_to :logiciel

  has_and_belongs_to_many :paquets
  has_and_belongs_to_many :binaires

  file_column :patch, :fix_file_extensions => nil

  validates_length_of :nom, :within => 3..100

  def self.content_columns
    @content_columns ||= columns.reject { |c| c.primary || 
        c.name =~ /(_id|_on|^patch)$/ || c.name == inheritance_column }     
  end

  def to_s
    index = patch.rindex('/')+ 1
    patch[index..-1]
  end

  alias_method :nom, :to_s

  def to_param
    "#{id}-#{nom.gsub(/[^a-z1-9]+/i, '-')}"
  end

  # Rien ne nous empeche, vue du mcd, d'avoir un correctif
  # sur plusieurs logiciels
  # TODO : a voir et a revoir
  def logiciels
    @logiciels ||= Logiciel.find(self.paquets.find(:all, :select => 
      'DISTINCT paquets.logiciel_id').collect{|p| p.logiciel_id})
    @logiciels
  end

  # date de reversement formattée
  # voir lib/overrides.rb pour les dates auto created _on et updated_on
  def reverse_le_formatted
      d = @attributes['reverse_le']
      "#{d[8,2]}.#{d[5,2]}.#{d[0,4]} à #{d[11,2]}h#{d[14,2]}"
  end

  # date de cloture formattée
  # voir lib/overrides.rb pour les dates auto created _on et updated_on
  def cloture_le_formatted
      d = @attributes['cloture_le']
      "#{d[8,2]}.#{d[5,2]}.#{d[0,4]} à #{d[11,2]}h#{d[14,2]}"
  end

  # délai (en secondes) entre la déclaration et l'acceptation
  # delai_to_s (texte)
  # en jours : sec2jours(delai)
  def delai
    if reverse
      (cloture_le - reverse_le)
    else
      -1
    end
  end

  # conditions de mise à jour d'un reversement
  # + "non clos" ET (updated_on > 1 mois)
  # + OU "à reverser"
  def todo(max_jours)
    # TODO : vérifier max_jours is integer
    age = ((Time.now - reverse_le)/(60*60*24)).round
    if !clos && age > max_jours.to_i
      # non clos && non maj
      return "mettre-à-jour" 
    elsif !reverse
      # non initialisé
      return "reverser"
    else 
      # rien à faire
      return false
    end
  end

  # retourne true si le reversement a commencé
  def reverse
    return false unless etatreversement
    etatreversement.id >= 1
  end

  # retourne true si l'état du reversement est final
  # "accepté", "refusé", "ne sera pas reversé"
  def clos
    return false unless etatreversement
    etatreversement_id >= 4 
  end

  # retourne true si le reversement est accepté
  def accepte
    return false unless etatreversement
    etatreversement_id == 4 
  end

private
  def find_logiciels
    paquets = self.paquets.find(:all, :select => 'DISTINCT paquets.logiciel_id')
    ids = paquets
    Logiciel.find(ids)
  end

end

