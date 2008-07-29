class Logiciel < ActiveRecord::Base
  acts_as_reportable
  acts_as_taggable
  
  has_one :image, :dependent => :destroy
  belongs_to :license
  belongs_to :groupe
  
  has_many :contributions
  has_many :knowledges
  has_many :demandes
  has_many :urllogiciels, :dependent => :destroy,
    :order => 'urllogiciels.typeurl_id'
  has_many :releases, :through => :versions
  has_many :versions, :order => "name DESC", :dependent => :destroy
  
  has_and_belongs_to_many :competences
  
  validates_presence_of :name, :message =>
    _('You have to specify a name')
  validates_presence_of :groupe, :message =>
    _('You have to specify a group')
  validates_length_of :competences, :minimum => 1, :message =>
    _('You have to specify at least one technology')

  # See ApplicationController#scope
  def self.set_scope(contract_ids)
    self.scoped_methods << { :find => { :conditions =>
        [ 'versions.contract_id IN (?)', contract_ids ],
        :include => [:versions]} } if contract_ids
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
  
  ContractReleases = Struct.new(:name, :id, :type)
  # Returns all the version and the last release of each version
  # Returns Array of ContractReleases
  def releases_contract(contract)
    result = []
    self.versions.find(:all, 
      :conditions => { "contracts.id" =>  contract.id }, 
      :joins => :contracts, :group => "versions.id").each do |v|
      
    end
    result
  end

  # For ruport
  def logiciels_name
    logiciel ? logiciel.name : '-'
  end

end
