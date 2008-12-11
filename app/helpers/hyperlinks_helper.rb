module HyperlinksHelper
  # Call it like this :
  #   link_to_new_hyperlink("contribution", @contribution.id)
  def link_to_new_hyperlink(model, model_id)
    return '-' if not model_id and not model
    options = { :model_id => model_id, :model_type => model.to_s }
    link_to(image_create('a hyperlink'), new_hyperlink_path(options))
  end
end
