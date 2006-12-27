#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Paquet < ActiveRecord::Base
  belongs_to :logiciel
  belongs_to :fournisseur
  belongs_to :distributeur
  belongs_to :contrat, :counter_cache => true
  belongs_to :mainteneur, :order => 'nom'
  belongs_to :conteneur
  has_many :fichiers, :dependent => :destroy
  has_many :changelogs, :dependent => :destroy
  has_many :dependances, :dependent => :destroy
  has_many :binaires, :dependent => :destroy

  has_and_belongs_to_many :correctifs

  def self.content_columns 
    @content_columns ||= columns.reject { |c| c.primary || 
        c.name =~ /(_id|taille|_count)$/ || c.name == inheritance_column } 
  end
  
  def to_param
    "#{id}-#{nom.gsub(/[^a-z1-9]+/i, '-')}"
  end

  # (cf Conventions de développement : wiki)
  # INCLUDE à mettre pour chaque finders
  INCLUDE = [ :conteneur ]
  ORDER = 'version, release DESC'
  def to_s
    "(#{conteneur.nom}) #{nom}-#{version}-#{release}"
  end
  
  # TODO : virer TOUT les to_display et les surcharges de nom de tous les modèles
  alias_method :to_display, :to_s


  def contournement(typedemande_id, severite_id)
    engagement(typedemande_id, severite_id).contournement
  end

  def correction(typedemande_id, severite_id)
    engagement(typedemande_id, severite_id).correction
  end

  private
  # mis en cache car rappelé souvent, notamment sur les binaires
  # d'un même paquet
  def engagement(typedemande_id, severite_id)
    @result = {} unless @result
    if (typedemande_id != @result[:typedemande] or severite_id != @result[:severite])
      @result[:engagement] = self.contrat.engagements.\
      find_by_typedemande_id_and_severite_id(typedemande_id,severite_id)
      @result[:typedemande], @result[:severite] = typedemande_id, severite_id
    end
    @result[:engagement]
  end

end
