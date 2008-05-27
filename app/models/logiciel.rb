class Logiciel < ActiveRecord::Base
  acts_as_reportable
  has_many :contributions
  has_and_belongs_to_many :competences
  has_many :demandes
  has_many :urllogiciels, :dependent => :destroy,
    :order => 'urllogiciels.typeurl_id'
  has_many :paquets, :order => "version DESC", :dependent => :destroy
  #belongs_to :communaute
  belongs_to :license
  belongs_to :groupe
  has_one :image, :dependent => :destroy

  has_many :binaires, :through => :paquets, :dependent => :destroy
  has_many :knowledges

  validates_presence_of :name, :message =>
    _('You have to specify a name')

  validates_length_of :competences, :minimum => 1, :message =>
    _('You have to specify at least one technology')

  # See ApplicationController#scope
  def self.set_scope(contrat_ids)
    self.scoped_methods << { :find => { :conditions =>
        [ 'paquets.contrat_id IN (?)', contrat_ids ],
        :include => [:paquets]} } if contrat_ids
  end

  # TODO : l'une des deux est de trop. Normalement c'est
  # uniquement content_columns
  def self.list_columns
    columns.reject { |c| c.primary ||
        c.name =~ /(_id|name|resume|description|referent)$/ ||
          c.name == inheritance_column }
  end

  def self.content_columns
    @content_columns ||= columns.reject { |c|
      c.primary || c.name =~ /(_id|_count|referent|Description)$/
    }
  end

  def to_param
    "#{id}-#{name.gsub(/[^a-z1-9]+/i, '-')}"
  end

  # For ruport
  def logiciels_name
    logiciel ? logiciel.name : '-'
  end

end
