#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
#used for static general classes

module Static

  # Create an action view not bound to any controller
  # usded to generate html tags from a static environement
  class ActionView
    include ::ActionView
    include ::ActionView::Helpers::AssetTagHelper
    include ::ActionView::Helpers::TagHelper

    @@av = ActionView.new
    def self.image_tag(path, op={})
      @@av.image_tag(path, op) || "O"
    end

    def self.image_path(path)
      @@av.image_path(path) || "O"
    end

    private

    # TODO -
    def compute_public_path(source,dir,ext)
      "#{relative_url_root}#{source}"
    end

    def relative_url_root
      #TODO
      "/images/"
    end
  end

end

