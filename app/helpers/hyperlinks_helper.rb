module HyperlinksHelper
  def link_to_new_hyperlink(model, model_id)
    return '-' if not model_id and not model
    options = new_hyperlink_path(:model_id => model_id, :model_type => model.to_s)
    link_to(image_create('a hyperlink'), options)
  end
end
