
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
  #   <%= link_to_show(@request) %>
  # Second, with an other controller :
  #   <%= link_to_show(edit_request_path(@request))%>
  def link_to_show(ar)
    return nil unless ar
    url = (ar.is_a?(String) ? ar : { :action => 'show', :id => ar })
    link_to StaticImage::view, url, { :class => 'nobackground' }
  end

  # same behaviour as link_to_show
  def link_to_edit(ar)
    return nil unless ar
    url = (ar.is_a?(String) ? ar : { :action => 'edit', :id => ar })
    link_to StaticImage::edit, url, { :class => 'nobackground' }
  end

  # same behaviour as link_to_show
  def link_to_delete(ar)
    return nil unless ar
    url = (ar.is_a?(String) ? ar : { :action => 'destroy', :id => ar })
    link_to StaticImage::delete,  url, :class => 'nobackground', :method => :delete,
        :confirm => _('Do you really want to destroy this object ?')
  end

  def link_to_back()
    link_to(StaticImage::back, :action =>'index')
  end


  def link_to_edit_and_list(ar)
    [ link_to_new, link_to_edit(ar), link_to_back ].compact.join(' | ')
  end

  def link_to_show_and_list(ar)
    [ link_to_show(ar), link_to_back ].compact.join('|')
  end


  # link_to_actions_table(demande)
  def link_to_actions_table(ar, options = {})
    return '' unless ar
    actions = [ link_to_show(ar), link_to_edit(ar), link_to_delete(ar) ]
    actions.compact!
    return "<td>#{actions.join('</td><td>')}</td>"
  end


  SPINNER_OPTIONS = { :before => "Element.show('spinner')",
    :success => "Element.hide('spinner')" }

  AJAX_OPTIONS =
    SPINNER_OPTIONS.dup.update(:update => 'content', :method => :get,
      :with => "Form.serialize(document.forms['filters'])"
    )

=begin
 call it like this :
 <%= show_pages_links @demande_pages, 'déposer une nouvelle demande' %>
 if you want ajax links, you must specificy the remote function this way :
 <%= show_pages_links @demande_pages, 'déposer une demande',
       :url => '/demandes/update_list' %>
 (!) you will need an StaticImage::spinner too (!)
 If you want to display a list of objects in a distant controller,
 e. g. : displaying the flow requests in reporting controller, then you
 need to precise the controller like this :
 <%= show_pages_links @demande_pages, 'déposer une demande',
       :controller => 'demandes' %>
  You have 2 parameters in options :
      :url : for ajaxified page links
      :no_new_links : avoid '+' links to create new one
        (used in 'to be done' request, for isntance).
=end
  def show_pages_links(pages, message, options = {} )
    if options.has_key? :url
      ajax_call =
        remote_function(AJAX_OPTIONS.dup.update(:url => options[:url]))
      options.delete :url
    end

    result = '<table class="pages"><tr>'
    unless options.has_key? :no_new_links
      result << "<td>#{link_to_new(message, options)}</td>"
    end
    return "<td>#{result}</td></tr></table>" unless pages.length > 0

    if pages.current.previous
      link = link_to_page(pages, pages.first, _('First page'),
                          StaticImage::first_page, ajax_call)
      result << "<td>#{link}</td>"
      link = link_to_page(pages, pages.current.previous, _('Previous page'),
                          StaticImage::previous_page, ajax_call)
      result << "<td>#{link}</td>"
    end
    if pages.current.last_item > 0
      result << "<td valign='middle'><small>&nbsp;#{pages.current.first_item}"
      result << _(' to ') << pages.current.last_item.to_s
      result << _('&nbsp; on ') << pages.last.last_item.to_s << '&nbsp;</small></td>'
    end
    if pages.current.next
      link = link_to_page(pages, pages.current.next, _('Next page'),
                          StaticImage::next_page, ajax_call)
      result << "<td>#{link}</td>"
      link = link_to_page(pages, pages.last, _('Last page'),
                          StaticImage::last_page,ajax_call)
      result << "<td>#{link}</td>"
    end
    result << '</tr></table>'
  end

  #To have a nice toogle element
  #Call it like this : toggle("my_id")
  #You just need a html element with an id="my_id"
  def toggle(id)
    images = image_tag("next_page.png", :id => "plus_#{id}") + image_tag("next_task.png", :id => "moins_#{id}", :style => "display: none")
    link_to_function(images, nil, :class => "no_hover") do |page|
      page[:"moins_#{id}"].toggle
      page[:"plus_#{id}"].toggle
      #page[:"#{id}"].visual_effect :blind_down
      page[:"#{id}"].toggle
    end
  end

  private
  ## intern functions
  # used in show_page_links
  def link_to_page(pages, page, title, image, ajax_call)
    html_options = {:title => title }
    if ajax_call
      page = "document.forms['filters'].page.value=#{page.number}; #{ajax_call}"
      link = link_to_function(image, page, html_options)
    else
      page = { :page => page }
      link = public_link_to(image, page, html_options)
    end
  end


end
