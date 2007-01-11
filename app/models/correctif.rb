#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Correctif < ActiveRecord::Base
  has_many :demandes
  has_many :reversements, :dependent => :destroy

  has_and_belongs_to_many :paquets
  has_and_belongs_to_many :binaires

  file_column :patch

  validates_length_of :nom, :within => 3..100

  def self.content_columns
    @content_columns ||= columns.reject { |c| c.primary || 
        c.name =~ /(_id|_on|^patch)$/ || c.name == inheritance_column }     
  end

  def to_s
    nom
  end

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

private
  def find_logiciels
    paquets = self.paquets.find(:all, :select => 'DISTINCT paquets.logiciel_id')
    ids = paquets
    Logiciel.find(ids)
  end

end

