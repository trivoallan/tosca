#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module PagesHelper

  # add_create_link
  # options :
  # permet de spécifier un controller
  def link_to_new(message='', options = {})
    link_options = options.update({:action => 'new'})
    link_to(image_create(message), link_options,
            { :class => 'nobackground' })
  end

  def link_to_view(ar)
    desc = 'Voir'
    link_to image_view, { :action => 'show', :id => ar.id }, {
      :class => 'nobackground' }
  end

  def link_to_edit_and_list(ar)
    [ link_to_edit(ar), link_to_back ].compact.join('|')
  end
  # add_edit_link(demande)
  def link_to_edit(ar, action = 'edit')
    desc = 'Editer'
    link_to image_edit, {
      :action => action, :id => ar }, { :class => 'nobackground' }
  end

  def link_to_modify(ar)
    link_to_edit(ar, 'modify')
  end

  # add_delete_link(demande)
  def link_to_delete(ar)
    desc = 'Supprimer'
    link_to image_delete, { :action => 'destroy', :id => ar },
    { :class => 'nobackground',
      :confirm => "Voulez-vous vraiment supprimer ##{ar.id} ?",
      :method => 'post' }
  end

  def link_to_back(desc='Retour à la liste', 
                   options = {:action => 'list', :id => nil })
    link_to(image_back, options)
  end

  # link_to_actions_table(demande)
  def link_to_actions_table(ar, options = {})
    return '' unless ar
    actions = [ link_to_view(ar), link_to_edit(ar), link_to_delete(ar) ]
    actions.compact!
    return "<td>#{actions.join('</td><td>')}</td>"
  end


  # Je veux voir ces commentaires dans l'email
  # Nom di diou
  
  # call it like this :
  # <%= show_pages_links @demande_pages, 'déposer une nouvelle demande' %>
  # if you want ajax links, you must specificy the remote function this way :
  # <%= show_pages_links @demande_pages, 'déposer une demande', 
  #        :url => '/demandes/update_list' %>
  # (!) you will need an image_spinner too (!)
  PAGE_FORM = 'document.forms[\'filters\']'
  AJAX_OPTIONS = { :update => 'content',
    :with => "Form.serialize(#{PAGE_FORM})",
    :before => "Element.show('spinner')",
    :success => "Element.hide('spinner')" }

  def show_pages_links(pages, message, options={})
    result = '<table class="pages"><tr><td>'
    result << "#{link_to_new(message, options)}</td>"
    return "<td>#{result}</td></tr></table>" unless pages.length > 0
    javascript = session[:javascript]
    if options[:url] and javascript
      ajax_call = remote_function(AJAX_OPTIONS.dup.update(options)) 
    end

    
    if pages.current.previous
      result << "<td>#{link_to_first_page(pages, ajax_call)}</td>"
      result << "<td>#{link_to_previous_page(pages, ajax_call)}</td>"
    end
    if pages.current.last_item > 0
      result << "<td valign='middle'><small>&nbsp;#{pages.current.first_item} "
      result << "à #{pages.current.last_item}&nbsp; sur #{pages.last.last_item}&nbsp;</small></td>"
    end
    if pages.current.next
      result << "<td>#{link_to_next_page(pages, ajax_call)}</td>"
      result << "<td>#{link_to_last_page(pages, ajax_call)}</td>"
    end
    result << '</tr></table>'
  end

  private
  ## intern functions
  # used in show_page_links
  def link_to_page(pages, page, title, image, ajax_call)
    html_options = {:title => title }
    if ajax_call
      page = "#{PAGE_FORM}.page.value=#{page}; #{ajax_call}"
      link = link_to_function(image, page, html_options)
    else
      page = { :page => pages.current.previous }
      link = link_to(image, page, html_options)
    end
  end

  # used in show_page_links
  def link_to_first_page(pages, ajax_call)
    html_options = {:title => 'Première page' }
    if ajax_call
      page = "#{PAGE_FORM}.page.value=1; #{ajax_call}"
      link = link_to_function(image_first_page, page, html_options)
    else
      page = { :page => pages.first }
      link = link_to(image_first_page, page, html_options)
    end
  end

  # used in show_page_links
  def link_to_last_page(pages, ajax_call)
      link_to(image_last_page, { :page => pages.last }, {
        :title => "Dernière page" }).to_s
  end

  # used in show_page_links
  def link_to_previous_page(pages, ajax_call)
      link_to(image_previous_page, { :page => pages.current.previous }, {
        :title => "Page précédente" }).to_s + '</td>'
  end

  # used in show_page_links
  def link_to_next_page(pages, ajax_call)
      link_to(image_next_page, { :page => pages.current.next }, {
        :title => "Page suivante" }).to_s + '</td>'
  end

end
