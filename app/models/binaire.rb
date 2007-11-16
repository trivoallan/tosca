#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Binaire < ActiveRecord::Base
  belongs_to :paquet
  belongs_to :socle, :counter_cache => true
  belongs_to :arch
  has_many :fichierbinaires, :dependent => :destroy
  has_and_belongs_to_many :contributions
  has_and_belongs_to_many :demandes

  file_column :archive, :fix_file_extensions => nil


  def self.set_scope(contrat_ids)
    self.scoped_methods << { :find => { :conditions =>
        [ 'paquets.contrat_id IN (?)', contrat_ids ],
        :include => [:paquet]} }
  end

  # belongs_to :contrat

  def self.content_columns
    @content_columns ||= columns.reject { |c| c.primary ||
        c.name =~ /(_id|^fichier)$/ || c.name == inheritance_column }
  end

  def to_s
    "#{name}-#{paquet.version}-#{paquet.release}"
  end

  ORDER = 'binaires.name ASC'
  INCLUDE = [:socle, :arch, :paquet]
  OPTIONS = {:order => ORDER, :include => INCLUDE }
end
