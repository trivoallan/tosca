#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
#used for static general classes

module Static

  # This is a singleton ActionView, created on first request
  # @see ApplicationController.set_global_shortcut
  # It's used to generate some html tags only once,
  # when asked. It's faster and do not uglify the code, 
  # so it's ok ;). Heavily used for images, @see static_image.rb for instance
  #
  class ActionView
    include ::ActionView
    include ::ActionView::Helpers::AssetTagHelper
    include ::ActionView::Helpers::TagHelper

    @@av = nil
    @@relative_url_root = nil
    def self.set_request(request)
      @@relative_url_root = "#{request.relative_url_root}/images/"
      @@av = ActionView.new
    end

    def self.image_tag(path, op={})
      @@av.image_tag(path, op) || "O"
    end

    def self.image_path(path)
      @@av.image_path(path) || "O"
    end

    def self.relative_url_root
      @@relative_url_root
    end

    private

    def compute_public_path(source,dir,ext)
      "#{@@relative_url_root}#{source}"
    end

    def relative_url_root
      @@relative_url_root
    end
  end

end

