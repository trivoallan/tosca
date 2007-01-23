#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module MailHelper

  def wrap(s, width=78)
    s.gsub!(/(.{1,#{width}})(\s+|\Z)/, "\\1\n")
  end

end
