#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module CommentairesHelper

  def display_history(comment)
    out = []
    name = "<b>#{comment.user.name}</b>"

    ingenieur = comment.ingenieur
    unless ingenieur.nil?
      if ingenieur.user_id == comment.user_id
        out << (_('This request has been taken into account by %s.') % name )
      else
        out << (_('This request has been assigned to %s by %s.') % 
                [ "<b>#{ingenieur.nom}</b>", name ])
      end
    end 
    statut = comment.statut
    unless statut.nil?
      out << (_('This request has been changed in %s by %s.') % 
              [ "<b>#{statut.nom}</b>", name ])
    end 
    severite = comment.severite
    unless severite.nil?
      out << (_('This request has been requalified in %s by %s.') % 
              [ "<b>#{severite.nom}</b>" , name ])
    end
    return nil if out.empty?
    '<div class="history">' << out.join('<br />') << '</div>'
  end
end
