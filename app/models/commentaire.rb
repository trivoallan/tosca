#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Commentaire < ActiveRecord::Base
  belongs_to :demande
  belongs_to :identifiant
  belongs_to :piecejointe, :dependent => :destroy
  belongs_to :statut
  
  validates_length_of :corps, :minimum => 5, :warn => "Vous devez mettre un commentaire d'au moins 5 caractères"

  # permet de récuperer l'état du commentaire en texte
  # le booléen correspondant est :  prive = true || false
  def etat
    ( prive ? "privé" : "public" )
  end

  def created_on_formatted
    d = @attributes['created_on']
    "#{d[8,2]}.#{d[5,2]}.#{d[0,4]} #{d[11,2]}:#{d[14,2]}"
  end


end
