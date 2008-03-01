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
                [ "<b>#{ingenieur.name}</b>", name ])
      end
    end
    statut = comment.statut
    unless statut.nil?
      out << (_('This request has been changed in %s by %s.') %
              [ "<b>#{statut.name}</b>", name ])
    end
    severite = comment.severite
    unless severite.nil?
      out << (_('This request has been requalified in %s by %s.') %
              [ "<b>#{severite.name}</b>" , name ])
    end
    elapsed = comment.elapsed
    unless elapsed.nil? || elapsed == 0
      elapsed = comment.demande.contrat.rule.formatted_elapsed(elapsed)
      out << (_('%s has been spent by %s on this request.') %
              [ "<b>#{elapsed}</b>" , name ])
    end
    return nil if out.empty?
    '<div class="history">' << out.join('<br />') << '</div>'
  end


  def display_comment(c)
    result = ''
    result << c.corps
    attachment = c.piecejointe
    unless attachment.blank? or attachment.file.blank?
      result << "<br /><br />#{StaticImage::folder} "
      result << link_to_file(attachment, "file").to_s
      result << " (#{file_size(attachment.file)})"
      result << link_to_file_redbox(attachment, :file).to_s
    end
    result
  end
end
