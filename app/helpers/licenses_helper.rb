module LicensesHelper
    # call it like :
  # <%= link_to_new_license %>
  def link_to_new_license()
    link_to_no_hover image_create(_('a copyright')), new_license_path
  end

end
