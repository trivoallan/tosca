#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module CommentairesHelper

  def display_history(comment)
    out = []
    nom = "<b>#{comment.identifiant.nom}</b>"

    ingenieur = comment.ingenieur
    unless ingenieur.nil?
      if ingenieur.identifiant_id == comment.identifiant_id
        out << (_('This request has been taken into account by %s.') % nom )
      else
        out << (_('This request has been assigned to %s by %s.') % 
                [ "<b>#{ingenieur.nom}</b>", nom ])
      end
    end 
    statut = comment.statut
    unless statut.nil?
      out << (_('This request has been changed in %s by %s.') % 
              [ "<b>#{statut.nom}</b>", nom ])
    end 
    severite = comment.severite
    unless severite.nil?
      out << (_('This request has been requalified in %s by %s.') % 
              [ "<b>#{severite.nom}</b>" , nom ])
    end
    return nil if out.empty?
    '<div class="history">' << out.join('<br />') << '</div>'
  end
end
