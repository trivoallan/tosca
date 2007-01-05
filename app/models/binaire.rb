#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Binaire < ActiveRecord::Base
  belongs_to :paquet
  belongs_to :socle
  belongs_to :arch
  has_many :fichierbinaires, :dependent => :destroy
  has_and_belongs_to_many :correctifs
  has_and_belongs_to_many :demandes

  file_column :archive


  # belongs_to :contrat

  def self.content_columns
    @content_columns ||= columns.reject { |c| c.primary || 
        c.name =~ /(_id|^fichier)$/ || c.name == inheritance_column }     
  end

  def to_s
    "#{nom}-#{paquet.version}-#{paquet.release}"
  end

  ORDER = 'binaires.nom ASC'
  INCLUDE = [:socle, :arch, :paquet]
  OPTIONS = {:order => ORDER, :include => INCLUDE }
end
