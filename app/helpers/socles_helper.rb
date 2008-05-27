module SoclesHelper

  # call it like :
  # <%= link_to_socle @socle %>
  def link_to_socle(s)
    return '-' unless s
    link_to s.name, socle_path(s)
  end

end
