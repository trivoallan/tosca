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
WillPaginate::ViewHelpers.pagination_options[:renderer] = ToscaRenderer
module WillPaginate::ViewHelpers
  def page_entries_info(collection)
    if collection.total_pages < 2
      case collection.size
      when 0; t('No entries found')
      when 1; t('Displaying <b>1</b> entry')
      else;   t("Displaying <b>all {{count}}</b> entries", :count => collection.size)
      end
    else
      t('Displaying entries <b>{{from}}&nbsp;-&nbsp;{{to}}</b> of <b>{{total}}</b> in total', :from => collection.offset + 1,
        :to => collection.offset + collection.length,
        :total => collection.total_entries
        )
    end
  end

  # Fix r#58 : restore create_link when there's no page
  def will_paginate_with_create_link(collection = nil, options = {})
    options, collection = collection, nil if collection.is_a? Hash
    page_links = will_paginate_without_create_link(collection, options)
    if page_links
      page_links
    else
      create_image = @template.image_create(options[:create_label])
      @template.link_to(create_image, { :action => 'new' })
    end
  end

  alias_method_chain :will_paginate, :create_link

end
