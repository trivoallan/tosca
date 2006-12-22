#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper


  def link_to_modify_account(id, title)
    link_to title, { 
      :action => 'modify', 
      :controller => 'account', 
      :id => id
    }
  end

  # Collection doit contenir des objects qui ont un 'id' et un 'nom'
  # objectcollection contient le tableau des objects déjà présents
  # C'est la fonction to_s qui est utilisée pour le label
  # L'option :size permettent une mise en colonne
  # Ex : hbtm_check_box( @logiciel.competences, @competences, 'competence_ids')
  def hbtm_check_box( objectcollection, collection, nom , options={})
    return '' if collection.nil?
    out = '<table><tr>' and count = 1
    for donnee in collection
      out << "<td><input type=\"checkbox\" id=\"#{donnee.id}\" "
      out << "name=\"#{nom}[]\" value=\"#{donnee.id}\" "
      out << 'checked="checked" ' if objectcollection and objectcollection.include? donnee
      out << "> #{donnee}</td>"
      out << '</tr><tr>' and count = 0 if options[:size] and options[:size] == count
      count += 1
    end
    out << '</tr></table>'
  end


  #  add_create_link
  # options :
  #  permet de spécifier un controller 
  def link_to_new(message='', options = {})
    link_options = options.update({:action => 'new'})
    link_to(image_tag("create_icon.png", :size => "16x16", 
                      :border => 0, :title => "Déposer #{message}", 
                      :alt => "Déposer #{message}" ), 
            link_options, 
            { :class => 'nobackground' })
  end

  # add_view_link(demande)
  def link_to_comment(ar)
    desc = 'Voir'
    link_to image_tag("icons/b_comment.png", :size => "15x15",  # "view_icon.gif", :size => "20x15", 
                      :border => 0, :title => desc, :alt => desc ), { 
      :action => 'comment', :id => ar}, { :class => 'nobackground' }
  end

  def link_to_view(ar)
    desc = 'Voir'
    link_to image_tag("icons/b_view.png", :size => "15x15", # "view_icon.gif", :size => "20x15",
                      :border => 0, :title => desc, :alt => desc ), { 
      :action => 'show', :id => ar }, { :class => 'nobackground' }
  end

  # add_edit_link(demande)
  def link_to_edit(ar)
    desc = 'Editer'
    link_to image_tag("icons/b_edit.png", :size => "15x15", # "edit_icon.gif", :size => "15x15",
                      :border => 0, :title => desc, :alt => desc ), {
      :action => 'edit', :id => ar }, { :class => 'nobackground' }
  end

  # add_delete_link(demande)
  def link_to_delete(ar)
    desc = 'Supprimer'
    link_to image_tag("icons/b_drop.png", :size => "15x17", # "delete_icon.gif", :size => "15x17", 
                             :border => 0, :title => desc, :alt => desc ), 
                             { :action => 'destroy', :id => ar }, 
                             { :class => 'nobackground', 
      :confirm => "Voulez-vous vraiment  supprimer ##{ar.id} ?", 
      :post => true }
  end

  def link_to_back(desc='Retour à la liste', options = {:action => 'list'})
    link_to(image_tag("back_icon.png", :size => "23x23",
                      :border => 0, :title => desc, 
                      :alt => desc, :align => 'baseline' ), 
            options)
  end

  # link_to_actions_table(demande)
  def link_to_actions_table(ar)
    return '' unless ar
    actions = [ link_to_view(ar), link_to_edit(ar), link_to_delete(ar) ]
    actions.compact!
    return "<td>#{actions.join('</td><td>')}</td>"
  end

  # call it like this :
  # <%= show_pages_links @demande_pages %>
  def show_pages_links(pages, message)
    result = '<table class="pages"><tr><td valign="baseline">'
    result << "#{link_to_new(message)}</td><td>"
    return "#{result}</td></tr></table>" unless pages.length > 0

    result << '<td>' + link_to(image_tag("first_page.png", :size => "14x14", :border => 0, :title => 'Première page', :alt => 'Première page'), { :page => pages.first }, { 
      :title => "Première page" }).to_s + '</td>'  if pages.current.previous
    result << '<td>' + link_to(image_tag("previous_page.png", :size => "14x14", :border => 0, :title => 'Page précédente', :alt => 'Page précédente'), { :page => pages.current.previous }, { 
      :title => "Page précédente" }).to_s + '</td>' if pages.current.previous
    result << "<td valign='middle'><small>&nbsp;#{pages.current.first_item} à #{pages.current.last_item}&nbsp; sur #{pages.last.last_item}&nbsp;</small></td>" if pages.current.last_item > 0
    result << '<td>' + link_to(image_tag("next_page.png", :size => "14x14", :border => 0, :title => 'Page suivante', :alt => 'Page suivante'), { :page => pages.current.next }, { 
      :title => "Page suivante" }).to_s + '</td>' if pages.current.next 
    result << '<td>' + link_to(image_tag("last_page.png", :size => "14x14", :border => 0, :title => 'Dernière page', :alt => 'Dernière page'), { :page => pages.last }, { 
      :title => "Dernière page" }).to_s + '</td>' if pages.current.next 
    result << '</tr></table>'
  end


  # fonction JS de mis à jour d'une boite select
  # Non utilisé pour l'instant
  def update_select_box( target_dom_id, collection, options={} )
    
    # Set the default options
    options[:text]           ||= 'name'
    options[:value]          ||= 'id'
    options[:include_blank]  ||= true
    options[:clear]     ||= []
    pre = options[:include_blank] ? [['','']] : []
    
    out = "update_select_options( $('" << target_dom_id.to_s << "'),"
    out << "#{(pre + collection.collect{ |c| [c.send(options[:text]), c.send(options[:value])]}).to_json}" << ","
    out << "#{options[:clear].to_json} )"
  end

  # Affiche un résumé texte succint d'une demande
  # Utilisé par exemple pour les balise "alt" et "title"
  # 
  def sum_up ( texte, limit=100)
    return texte unless (texte.is_a? String) && (limit.is_a? Numeric)
    out = ""
    out << texte[0..limit]
    out << '...' if texte.length > limit
    out
  end 

  def indent( text )
    return text unless text.is_a? String
    text = h text
    text.gsub(/[\n]/, "<br />")
  end

  def file_size( file )
    if File.exist?(file)
      human_size(File.size(file)) 
    else
      "N/A"
    end
  end
  
  # Call it like this : link_to_file(document, 'fichier', 'nomfichier')
  def link_to_file(record, file)
    if record and File.exist?(record.send(file))
      nom = record.send(file)[/[._ \-a-zA-Z0-9]*$/] 
      link_to nom, url_for_file_column(record, file, :absolute => true) 
    else
      "N/A"
    end
  end


  # options : 
  #  * no_title : permet de ne pas mettre de titre à la liste
  # Call it like : <%= show_liste(@correctif.binaires, 'correctif') {|e| e.nom} %>
  def show_liste(elements, nom, options = {})
    size = elements.size
    return "<u><b>Aucun(e) #{nom}</b></u>" unless size > 0
    result = ''
    unless options[:no_title]
      result << "<p><b>#{pluralize(size, nom.capitalize)} : </b><br />"
    end

    result << '<ol>'
    elements.each { |e| result << '<li>' + yield(e) + '</li>' }
    result << '</ol>'

  end

  # Call it like : 
  # <% titres = ['Fichier', 'Taille', 'Auteur', 'Maj'] %>
  # <%= show_table(@documents, Document, titres) { |e| "<td>#{e.nom}" } %>
  # N'oubliez pas d'utiliser les <td></td>
  # 2 options, :total et :content_columns
  # La première désactive le décompte total si positionné à false
  # La deuxième active l'affichage des content_columns si positionné à true
  def show_table(elements, ar, titres, options = {})
    return "<br/><p>Aucun #{ar.table_name.singularize} à ce jour</p>" unless elements and elements.size > 0
    width = ( options[:width] ? "width=#{options[:width]}" : "" )
    result = "<table #{width}><tr>"

    if (options[:content_columns])
      ar.content_columns.each{|c| result <<  "<th>#{c.human_name}</th>"}
    end
    titres.each {|t| result << "<th>#{t}</th>" }
    
    result << '</tr>'
    elements.each_index { |i| 
      result << "<tr class=\"#{(i % 2)==0 ? 'pair':'impair'}\">"
      if (options[:content_columns])
        ar.content_columns.each {|column| 
          result << "<td>#{indent elements[i].send(column.name)}</td>" 
        }
      end
      result << yield(elements[i])
      result << '</tr>' 
    }
    result << '</tr></table>'
    # result << show_total(elements.size, ar, options)
  end

  # show_total(elements.size, ar, options)
  # Valid options
  # :total => false (affiche la taille des éléments et pas un ActiveRecord.count)
  def show_total(size, ar, options = {})
    if options[:total] == false
      result = "<p><b>#{size}</b> "
    else
      result = "<p><b>#{ar.count}</b> "
    end
    result << (size==1? ar.table_name.singularize : ar.table_name.pluralize)
    result << '</p>'  
  end


  #affiche le nombre de jours ou un "Sans objet"
  def display_jours(temps)
    return temps unless temps.is_a? Numeric
    case temps
    when -1 then "Sans objet"
    when 1 then "1 jour ouvré"
    else temps.to_s + " jours ouvrés"
    end
  end


  # select_onchange(@clients, @current_client, 'client')
  def select_onchange(list, default, name)
    options = {:onchange => 'this.form.submit();'}
    select = options_for_select(list.collect{|l| 
                                  sum_up(l.nom, 25)}.unshift(['','']), 
                                default.to_i)
    return select_tag(name, select, options)
  end


  def display_seconds(temps)
    return temps #unless temps.is_a? Numeric
#    temps==-1 ? "sans engagement" : distance_of_time_in_french_words(temps) + " "
  end


end
