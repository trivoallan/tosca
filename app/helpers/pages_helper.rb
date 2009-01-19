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

module PagesHelper
  # add_create_link
  # options :
  # permet de spécifier un controller
  def link_to_new(message='', options = {})
    options[:action] = 'new'
    html_options = LinksHelper::ALIGNED_PICTURE
    link_to(image_create(message), options, html_options)
  end

  # 2 ways of use it
  # First, within the good controller :
  #   <%= link_to_show(@issue) %>
  # Second, with an other controller :
  #   <%= link_to_show(edit_issue_path(@issue))%>
  def link_to_show(ar)
    return nil unless ar
    url = (ar.is_a?(String) ? ar : { :action => 'show', :id => ar })
    link_to StaticPicture::view, url
  end

  # same behaviour as link_to_show
  def link_to_edit(ar)
    return nil unless ar
    url = (ar.is_a?(String) ? ar : { :action => 'edit', :id => ar })
    link_to StaticPicture::edit, url
  end

  # same behaviour as link_to_show
  def link_to_delete(ar)
    return nil unless ar
    url = (ar.is_a?(String) ? ar : { :action => 'destroy', :id => ar })
    link_to StaticPicture::delete,  url, :method => :delete,
        :confirm => _('Do you really want to destroy this object ?')
  end

  def link_to_back
    link_to(StaticPicture::back, :action =>'index')
  end

  def link_to_edit_and_list(ar)
    [ link_to_new, link_to_edit(ar), link_to_back ].compact.join(' | ')
  end

  def link_to_show_and_list(ar)
    [ link_to_show(ar), link_to_back ].compact.join('|')
  end

  # link_to_actions_table(issue)
  def link_to_actions_table(ar)
    return '' unless ar
    actions = [ link_to_show(ar), link_to_edit(ar), link_to_delete(ar) ]
    actions.compact!
    return "<td>#{actions.join('</td><td>')}</td>"
  end


  SPINNER_OPTIONS = { :before => "Element.show('spinner')",
    :success => "Element.hide('spinner')" }

  AJAX_OPTIONS =
    SPINNER_OPTIONS.dup.update(:update => 'col1_content', :method => :get,
      :with => "Form.serialize(document.forms['filters'])"
    )

=begin
 call it like this :
 <%= show_pages_links @issue_pages, 'déposer une nouvelle issue' %>
 if you want ajax links, you must specificy the remote function this way :
 <%= show_pages_links @issue_pages, 'déposer une issue',
       :url => '/issues/update_list' %>
 (!) you will need an StaticPicture::spinner too (!)
 If you want to display a list of objects in a distant controller,
 e. g. : displaying the flow issues in reporting controller, then you
 need to precise the controller like this :
 <%= show_pages_links @issue_pages, 'déposer une issue',
       :controller => 'issues' %>
  You have 2 parameters in options :
      :url : for ajaxified page links
      :no_new_links : avoid '+' links to create new one
        (used in 'to be done' issue, for isntance).
=end
  def show_pages_links(pages, message, options = {} )
    if options.has_key? :url
      ajax_call =
        remote_function(AJAX_OPTIONS.dup.update(:url => options[:url]))
      options.delete :url
    end

    result = '<table><tr>'
    unless options.has_key? :no_new_links
      result << "<td>#{link_to_new(message, options)}</td>"
    end
    return "<td>#{result}</td></tr></table>" unless pages.length > 0

    if pages.current.previous
      link = link_to_page(pages.first, _('First page'),
                          StaticPicture::first_page, ajax_call)
      result << "<td>#{link}</td>"
      link = link_to_page(pages.current.previous, _('Previous page'),
                          StaticPicture::previous_page, ajax_call)
      result << "<td>#{link}</td>"
    end
    if pages.current.last_item > 0
      result << "<td valign='middle'><small>&nbsp;#{pages.current.first_item}"
      result << _(' to ') << pages.current.last_item.to_s
      result << _('&nbsp; on ') << pages.last.last_item.to_s << '&nbsp;</small></td>'
    end
    if pages.current.next
      link = link_to_page(pages.current.next, _('Next page'),
                          StaticPicture::next_page, ajax_call)
      result << "<td>#{link}</td>"
      link = link_to_page(pages.last, _('Last page'),
                          StaticPicture::last_page,ajax_call)
      result << "<td>#{link}</td>"
    end
    result << '</tr></table>'
  end

  #To have a nice toogle element
  #Call it like this : toggle("my_id")
  #You just need a html element with an id="my_id"
  def toggle(id)
    images = image_tag("icons/navigation_expand.gif", :id => "show_#{id}") +
      image_tag("icons/navigation_hide.gif", :id => "hide_#{id}", :style => "display: none")
    link_to_function(images, nil) do |page|
      page[:"hide_#{id}"].toggle
      page[:"show_#{id}"].toggle
      page[:"#{id}"].toggle
    end
  end

  #To have a nice div to click on to toggle on other tag
  #Call it like this :
  #<%= div_toggle("Some text", "id") %>
  #<ul id="id">
  #</ul>
  #Options :
  #Any reguler html_options (like :class, etc)
  #hide : The toggle tag is hiden by default
  def div_toggle(value, id, options = {})
    options[:onclick] = update_page do |page|
      page[:"hide_#{id}"].toggle
      page[:"show_#{id}"].toggle
      page.visual_effect :toggle_blind, id, :duration => 0.5
    end

    style_hide, style_show = '', ''
    style_hide = 'display: none' unless options.has_key?(:hide)
    style_show = 'display: none' if options.has_key?(:hide)
    options.delete(:hide)

    result = tag('div', options, true)
    result << image_tag("icons/navigation_hide.gif",
      :id => "show_#{id}", :style => style_show)
    result << image_tag("icons/navigation_expand.gif",
      :id => "hide_#{id}", :style => style_hide)
    result << "&nbsp;#{value}"
    result << '</div>'
  end

  private
  ## intern functions
  # used in show_page_links
  def link_to_page(page, title, image, ajax_call)
    html_options = {:title => title }
    if ajax_call
      page = "document.forms['filters'].page.value=#{page.number}; #{ajax_call}"
      link_to_function(image, page, html_options)
    else
      page = { :page => page }
      public_link_to(image, page, html_options)
    end
  end

end
