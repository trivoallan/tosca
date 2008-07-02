class Paquet < ActiveRecord::Base
  belongs_to :logiciel
  belongs_to :contract, :counter_cache => true
  belongs_to :mainteneur
  belongs_to :conteneur
  
  has_many :changelogs, :dependent => :destroy
  has_many :binaires, :dependent => :destroy, :include => :version
  has_and_belongs_to_many :contributions

  validates_presence_of :logiciel, :conteneur, :contract

  def self.content_columns
    @content_columns ||= columns.reject { |c| c.primary ||
        c.name =~ /(_id|taille|configuration|_count)$/ || c.name == inheritance_column }
  end

  # See ApplicationController#scope
  def self.set_scope(contract_ids)
    self.scoped_methods << { :find => { :conditions =>
        [ 'versions.contract_id IN (?)', contract_ids ]} }
  end

  def to_param
    "#{id}-#{name.gsub(/[^a-z1-9]+/i, '-')}"
  end

  # (cf Conventions de développement : wiki)
  ORDER = 'versions.name, versions.version, versions.release DESC'
  OPTIONS = { :order => ORDER }

  def self.get_scoped_methods
    scoped_methods
  end

  def to_s
    [ name, version, release ].compact.join('-') << " (#{conteneur.name})"
  end

  def contournement(typedemande_id, severite_id)
    engagement(typedemande_id, severite_id).contournement
  end

  def correction(typedemande_id, severite_id)
    engagement(typedemande_id, severite_id).correction
  end

  private
  # mis en cache car rappelé souvent, notamment sur les binaires
  # d'un même version
  # TODO : recoder, utiliser plus souvent. Et utiliser un engagement vide
  # si il n'existe pas, grâce à rescue ..NotFoundException
  def engagement(typedemande_id, severite_id)
    @result = {} unless @result
    if (typedemande_id != @result[:typedemande] or severite_id != @result[:severite])
      @result[:engagement] = self.contract.engagements.\
      find_by_typedemande_id_and_severite_id(typedemande_id,severite_id)
      @result[:typedemande], @result[:severite] = typedemande_id, severite_id
    end
    @result[:engagement]
  end

end
