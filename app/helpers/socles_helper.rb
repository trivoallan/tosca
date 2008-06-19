module SoclesHelper

  # call it like :
  # <%= link_to_socle @socle %>
  def link_to_socle(s)
    return '-' unless s
    link_to s.name, socle_path(s)
  end

  def link_to_new_socle
    link_to(image_create(_('a system')), new_socle_path, LinksHelper::NO_HOVER)
  end
end
