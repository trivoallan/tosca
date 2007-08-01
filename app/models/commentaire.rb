#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Commentaire < ActiveRecord::Base
  belongs_to :demande
  belongs_to :identifiant
  belongs_to :piecejointe
  belongs_to :statut
  belongs_to :severite
  belongs_to :ingenieur

  validates_length_of :corps, :minimum => 5,
          :warn => _("Vous devez mettre un commentaire d'au moins 5 caractères")

  # On détruit l'éventuelle pièce jointe
  # le belongs_to ne permet pas d'appeler :dependent :'(


  # TODO scope sur les commentaires privés/public

  # permet de récuperer l'état du commentaire en texte
  # le booléen correspondant est :  prive = true || false
  def etat
    ( prive ? _("private") : _("public") )
  end

  # after_save :update_demande

  before_destroy :delete_pj

  private
  def delete_pj
    self.piecejointe.destroy unless self.piecejointe.nil?
  end

  def update_demande
    fields = %w{statut_id ingenieur_id severite_id}
    modified = false
    #On met à jour les champs demandeO
    fields.each do |attr|
      #On ne met à jour que si ça a changé
      if self[attr] and self.demande[attr] != self[attr]
        self.demande[attr] = self[attr]
        modified = true
      end
    end
    #Dirty hack to update the request only when we are editing the first comment
    if self.demande.first_comment_id == self.id and self.demande.description != self.corps
      self.demande.description = self.corps
      modified = true
    end
    self.demande.save if modified
  end

end
