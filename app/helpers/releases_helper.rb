module ReleasesHelper

  def link_to_release(release)
    return '-' unless release and release.version
    link_to release.to_s, release_patch(release.id)
  end

  # Link to create a new url for a release
  def link_to_new_release(version_id)
    return '-' if version_id.blank?
    options = new_release_path(:version_id => version_id)
    link_to_no_hover image_create(_('release')), options
  end

end
