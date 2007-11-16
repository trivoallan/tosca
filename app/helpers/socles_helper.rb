#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module SoclesHelper

  # call it like :
  # <%= link_to_socle @socle %>
  def link_to_socle(s)
    return '-' unless s
    link_to s.name, socle_path(s)
  end

end
