module DistributeursHelper
  # call it like :
  # <%= link_to_new_distributeur %>
  def link_to_new_distributeur()
    link_to_no_hover image_create(_('a distributor')), new_distributeur_path
  end

end
