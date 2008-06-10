class Binaire < ActiveRecord::Base
  belongs_to :paquet
  belongs_to :socle, :counter_cache => true
  belongs_to :arch
  has_and_belongs_to_many :contributions

  file_column :archive, :fix_file_extensions => nil

  validates_presence_of :paquet

  # paquet association MUST be loaded by each reference on this model
  def self.set_scope(contract_ids)
    self.scoped_methods << { :find => { :conditions =>
       [ 'paquets.contract_id IN (?)', contract_ids ] } }
  end

  # belongs_to :contract

  def self.content_columns
    @content_columns ||= columns.reject { |c| c.primary ||
        c.name =~ /(_id|^fichier)$/ || c.name == inheritance_column }
  end

  def to_s
    "(#{arch.name}) " << [ name, paquet.version, paquet.release ].compact.join('-')
  end

  ORDER = 'binaires.name ASC'
  INCLUDE = [:socle, :arch, :paquet]
  OPTIONS = {:order => ORDER, :include => INCLUDE }
end
