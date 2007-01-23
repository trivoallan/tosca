#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module MailHelper

  # met en forme du texte sur [width] colonnes
  # TODO : ne pas supprimer les saut de lignes (cf mails)
  def wrap(s, width=78)
    s.gsub!(/(.{1,#{width}})(\s+|\Z)/, "\\1\n")
  end

end
