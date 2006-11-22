#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Paquet < ActiveRecord::Base
  belongs_to :logiciel
  belongs_to :fournisseur
  belongs_to :arch
  has_many :fichiers, :dependent => :destroy
  belongs_to :socle
  belongs_to :contrat
  has_many :changelogs, :dependent => :destroy
  belongs_to :distributeur
  has_many :dependances, :dependent => :destroy
  belongs_to :mainteneur, :order => 'nom'
  belongs_to :conteneur

  has_and_belongs_to_many :demandes


  def self.content_columns 
    @content_columns ||= columns.reject { |c| c.primary || 
        c.name =~ /(_id|taille)$/ || c.name == inheritance_column } 
  end
  
  def to_param
    "#{id}-#{nom.gsub(/[^a-z1-9]+/i, '-')}"
  end

  #return a string in the format %nom-%version-%release
  def to_display
    "#{nom}-#{version}-#{release}"
  end
end
