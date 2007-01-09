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

  def mes_demandes(beneficiaire)
    if beneficiaire
      demandes.find_all_by_beneficiaire_id(beneficiaire.client.beneficiaires)
    else
      demandes
    end
  end

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

end

