#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Correctif < ActiveRecord::Base
  has_many :binaires, :dependent => :destroy
  has_many :demandes
  has_many :reversements, :dependent => :destroy

  file_column :patch

  validates_length_of :nom, :within => 3..25

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
end
