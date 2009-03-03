#
# Copyright (c) 2006-2009 Linagora
#
# This file is part of Tosca
#
# Tosca is free software, you can redistribute it and/or modify
# it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
# Tosca is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
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
    include FastGettext::Translation

    @@av = nil
    @@relative_url_root = nil
    def self.set_url_root()
      @@relative_url_root = "#{ActionController::Base.relative_url_root}/images/"
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

    def compute_public_path(source, dir, ext=nil)
      "#{@@relative_url_root}#{source}"
    end

    def relative_url_root
      @@relative_url_root
    end
  end

end
