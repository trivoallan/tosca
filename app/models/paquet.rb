#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Paquet < ActiveRecord::Base
  belongs_to :logiciel
  belongs_to :fournisseur
  belongs_to :distributeur
  belongs_to :contrat, :counter_cache => true
  belongs_to :mainteneur, :order => 'name'
  belongs_to :conteneur
  has_many :fichiers, :dependent => :destroy
  has_many :changelogs, :dependent => :destroy
  has_many :dependances, :dependent => :destroy
  has_many :binaires, :dependent => :destroy


  def self.content_columns
    @content_columns ||= columns.reject { |c| c.primary ||
        c.name =~ /(_id|taille|_count)$/ || c.name == inheritance_column }
  end

  def self.set_scope(contrat_ids)
    self.scoped_methods << { :find => { :conditions =>
        [ 'paquets.contrat_id IN (?)', contrat_ids ]} }
  end

  def to_param
    "#{id}-#{name.gsub(/[^a-z1-9]+/i, '-')}"
  end

  # (cf Conventions de développement : wiki)
  # INCLUDE à mettre pour chaque finders
  INCLUDE = [ :conteneur ]
  ORDER = 'paquets.name, paquets.version, paquets.release DESC'
  OPTIONS = { :include => INCLUDE, :order => ORDER }

  def self.get_scoped_methods
    scoped_methods
  end

  def to_s
    the_name = _('unknown_name')
    the_name = conteneur.name unless conteneur.nil?
    "%s %s-%s-%s" % [ the_name, name, version, release]
  end

  def contournement(typedemande_id, severite_id)
    engagement(typedemande_id, severite_id).contournement
  end

  def correction(typedemande_id, severite_id)
    engagement(typedemande_id, severite_id).correction
  end

  private
  # mis en cache car rappelé souvent, notamment sur les binaires
  # d'un même paquet
  # TODO : recoder, utiliser plus souvent. Et utiliser un engagement vide
  # si il n'existe pas, grâce à rescue ..NotFoundException
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
