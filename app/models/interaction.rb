#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Interaction < ActiveRecord::Base

  belongs_to :logiciel, :counter_cache => true
  # TODO : remplacer relation :client par :demande
  # has_one :demande 
  belongs_to :client, :counter_cache => true
  belongs_to :ingenieur, :counter_cache => true, :include => [:identifiant]
  has_one :reversement

  validates_length_of :url_de_suivi, :minimum => 8,
   :too_short => "Vous devez spécifier l'url de suivi de l'interaction" 

  def self.content_columns 
    @content_columns ||= columns.reject { |c| c.primary || 
        c.name =~ /(_id|url_de_suivi)$/ || c.name == inheritance_column } 
  end

  # TODO : supprimer mantis apres le migrate
  def id_mantis
    false #111
  end

  # TODO : supprimer demande apres le migrate
  def demande
    Demande.find_first
  end 

end
