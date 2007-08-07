#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module CommentairesHelper

  def display_history(comment)
    out = []
    identifiant = comment.identifiant
    unless identifiant.nil?
      out << _('The <b>owner</b> of your request is') << 
        " <b>#{identifiant.nom}</b>"
    end 
    statut = comment.statut
    unless statut.nil?
      out << _('The <b>status</b> of your request is') << 
        " <b>#{statut.nom}</b>"
    end 
    severite = comment.severite
    unless severite.nil?
      out _('The <b>severity</b> of your request is') <<
        "<b>#{severite.nom}</b>"
    end
    '<span class="history">' << out.join('<br />') << '</span>'
  end
end
