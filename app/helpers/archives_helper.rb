module ArchivesHelper
  
  def link_to_archive(archive)
    return '-' unless archive and archive.name
    link_to archive.name, archive_patch(archive.id)
  end

  # Link to create a new url for a archive
  def link_to_new_archive(release_id)
    return '-' if release_id.blank?
    options = new_archive_path(:release_id => release_id)
    link_to_no_hover image_create(_('archive')), options
  end
  
end
