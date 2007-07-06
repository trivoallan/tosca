#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module BienvenueHelper

  def html_wrap(s, width=78)
    s.gsub!(/(.{1,#{width}})(\s+|\Z)/, "\\1<br />")
  end

end

