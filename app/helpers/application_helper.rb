#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################

# Methods added to this helper will be available to all templates in the application.
# This is a big helper, so find by keyword :
# - FORMULAIRES
# - LIENS ABSOLUS
# - LIENS RELATIFS
# - AJAX ET JAVASCRIPT
# - TEXTE
# - FILES
# - LISTES ET TABLES
# - TIME
module ApplicationHelper

  include ImagesHelper

  def search_demande(options = {})
    text_field('numero', '', 'size' => 3)
  end


  ### FORMULAIRES #############################################################

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

  # Collection doit contenir des objects qui ont un 'id' et un 'nom'
  # objectcollection contient le tableau des objects déjà présents
  # C'est la fonction to_s qui est utilisée pour le label
  # Ex : hbtm_radio_button( @logiciel.competences, @competences, 'competence_ids') 
  def hbtm_radio_button( objectcollection, collection, nom )
    return '' if collection.nil?
    out = ""
    for donnee in collection
      out << "<input type=\"radio\" id=\"#{donnee.id}\" "
      out << "name=\"#{nom}[]\" value=\"#{donnee.id}\" "
      out << 'checked="checked" ' if objectcollection and objectcollection.include? donnee
      out << "> #{donnee} </input>"
    end
    out
  end

  # select_onchange(@clients, @current_client, 'client')
  # options
  # :width limite la taille du texte en nb de caractères
  # :title à afficher comme 1er élément de la liste (no value)
  # :onchange action si changement
  # :size hauteur du select
  def select_onchange(list, default, name, options = {})
    # options[:width] ||= 15
    options[:title] ||= '' 
    options[:onchange] ||= 'this.form.submit();'
    collected = list.collect{|e| [sum_up(e.nom, options[:width]), e.id] }.unshift(["#{options[:title]}", ''])
    select = options_for_select(collected, default.to_i)
    return select_tag(name, select, options) 
  end


  # Titles doit contenir un tableau
  # Champs doit contenir un tableau
  # Les éléments de Titles et Champs doivent être affichable par to_s
  # options 
  # :title => Donne un titre au tableau
  # :subtitle => Donne un sous titre au tableau
  # Ex : show_table_form( { "TOTO", "TITI"}, { "TATA", "TUTU" }, :title => "Titre" )
  def show_table_form(fields, options = {})
    fields.compact!
    result = ''
    style = "class='#{options[:class]}'" if options[:class]
    result << "<table #{style}>"
    fields.each { |f|
      title, field = f.first, f.last
      unless title.nil? and field.nil?
        result << '<tr>'
        if field.nil? 
          result << '<td colspan="2">' << title << '</td>'
        elsif title.nil?
          result << '<td colspan="2">' << field << '</td>'
        else
          result << "<td>#{title}</td>"
          result << "<td>#{field}</td>"
        end
        result << '</tr>'
      end
    }
  result << '</table>'
  end

  def lstm_text_field(label, mmodel, field, options = {})
    [ "<label for=\"#{mmodel}_#{field}\">#{label}</label>", 
      text_field(mmodel, field, options) ]
  end

  def lstm_password_field(label, model, field, options = {})
    [ "<label for=\"#{model}_#{field}\">#{label}</label>", 
      password_field(model, field, options) ]
  end

  def lstm_text_area(label, model, field, options = {})
    [ "<label for=\"#{model}_#{field}\">#{label}</label>", 
      text_area(model, field, options) ]
  end

  ### LIENS ABSOLUS ################################################################

  # lien vers un compte existant
  # DEPRECATED : préferer link_to_edit(id)
  # TODO : passer id en options, avec @session[:user].id par défaut
  # TODO : title en options, avec 'Le compte' par défaut
  def link_to_modify_account(id, title, options = {})
    link_to title, { 
      :action => 'modify', 
      :controller => 'account', 
      :id => id
    }
  end

  # lien vers mon compte
  # TODO : ne pas utiliser.
  #        à préférer :  link_to_modify_account({:text => 'Mon&nbsp;compte'})
  def link_to_my_account(options = {:text => 'Mon&nbsp;compte'})
    link_to_modify_account(session[:user].id, options[:text]) if session[:user]
  end

  # lien vers mon offre / mon client
  # TODO options[:text] doit prendre l'image si options[:image]
  # options
  # :text texte du lien à afficher
  # :image image du client à afficher à la place
  def link_to_my_client(options = {:text => 'Mon&nbsp;Offre'})
    return unless session[:beneficiaire]
    if options[:image]
      link_to image_tag(url_for_file_column(@beneficiaire.client.photo, 'image', 'thumb')), 
      :controller => 'clients', :action => 'show', :id => session[:beneficiaire].client_id
    else 
      link_to options[:text],  
      :controller => 'clients', :action => 'show', :id => session[:beneficiaire].client_id
    end
  end

  # lien vers la consultation d'UN logiciel
  def link_to_logiciel(logiciel)
      if logiciel
        link_to logiciel.nom, :controller => 'logiciels', :action => 'show', :id => logiciel.id
      else 
        # cas où le logiciel n'existe pas/plus
        "logiciel inconnu"
      end
  end

  # lien vers la consultation d'UN groupe
  def link_to_groupe(groupe)
      link_to groupe.nom, :controller => 'groupes', :action => 'show', :id => groupe.id
  end

  # add_view_link(demande)
  def link_to_comment(ar)
      link_to image_view, { :controller => 'demandes', :action => 'comment', 
        :id => ar}, { :class => 'nobackground' }
  end

  # un correctif peut être liée à une demande externe
  # le "any" indique que la demande peut etre sur n'importe quel tracker
  # TODO : verifier que le paramètre est un correctif
  def link_to_any_demande(correctif)
    return "Aucune demande associée" if !correctif.id_mantis && correctif.demandes.size == 0
    out = []
    if correctif.id_mantis
      out << "<a href=\"http://www.08000linux.com/clients/minefi_SLL/mantis/view.php?id=#{correctif.id_mantis}\">
       Mantis ##{correctif.id_mantis}</a>"
    end
    correctif.demandes.each {|d|
      out << "#{link_to_demande(d, {:show_id => true, :pre_text => 'Lstm'})}"
    }
    out * '<br/>'
  end


  ### LIENS RELATIFS ##############################################################

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
  def link_to_edit(ar)
    desc = 'Editer'
    link_to image_edit, {
      :action => 'edit', :id => ar }, { :class => 'nobackground' }
  end

  # add_delete_link(demande)
  def link_to_delete(ar)
    desc = 'Supprimer'
    link_to image_delete, { :action => 'destroy', :id => ar }, 
    { :class => 'nobackground', 
      :confirm => "Voulez-vous vraiment  supprimer ##{ar.id} ?", 
      :method => 'post' }
  end

  def link_to_back(desc='Retour à la liste', options = {:action => 'list'})
    link_to(image_back, options)
  end

  # link_to_actions_table(demande)
  def link_to_actions_table(ar, options = {})
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

    if pages.current.previous
      result << '<td>' + link_to(image_first_page, { :page => pages.first }, { 
        :title => "Première page" }).to_s + '</td>' 
      result << '<td>' + link_to(image_previous_page, { :page => pages.current.previous }, { 
        :title => "Page précédente" }).to_s + '</td>'
    end
    if pages.current.last_item > 0
      result << "<td valign='middle'><small>&nbsp;#{pages.current.first_item} "
      result << "à #{pages.current.last_item}&nbsp; sur #{pages.last.last_item}&nbsp;</small></td>" 
    end
    if pages.current.next 
      result << '<td>' + link_to(image_next_page, { :page => pages.current.next }, { 
        :title => "Page suivante" }).to_s + '</td>' 
      result << '<td>' + link_to(image_last_page, { :page => pages.last }, { 
        :title => "Dernière page" }).to_s + '</td>'
    end
    result << '</tr></table>'
  end

  # lien vers l'export de données
  # options : 
  #  :data permet de spécifier un autre nom de controller (contexte par défaut)
  def link_to_export(options={})
    # TODO : tester si ExportController a une public_instance_methods du nom du controller
    cname = ( options[:data] ? options[:data] : controller.controller_name)
    link_to "Exporter les #{cname}", :controller => 'export', :action => cname
  end


  ### AJAX ET JAVASCRIPT ##########################################################

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


  ### TEXTE ######################################################################

  # Affiche un résumé texte succint d'une demande
  # Utilisé par exemple pour les balise "alt" et "title"
  # on affiche '...' si le reste a afficher fait plus de 3 caracteres
  def sum_up ( texte, limit=100, options ={:less => '...'})
    return texte unless (texte.is_a? String) && (limit.is_a? Numeric)
    out = ""
    if texte.size <= limit+3
      out << texte
    elsif
      out << texte[0..limit] 
      out << options[:less]
    end
    out
  end 

  def indent( text )
    return text unless text.is_a? String
    text = h text
    text.gsub(/[\n]/, "<br />")
  end

  def show_help(help_text, options = {:symbol => '?'})
    "<a alt=\"#{help_text}\" title=\"#{help_text}\" >#{options[:symbol]}</a>"
  end

  def show_title(title, options = {})
    return unless title
    result = '<br/>'
    result << "<h1>#{title}</h1>"
    if options[:subtitle]
      result << "<h2>#{options[:subtitle]}</h2>"
    else
      result << "<br/>"
    end
  end


  ### FILES ######################################################################

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


  ### LISTES ET TABLES ############################################################

  # Affiche une liste d'élements dans une cellule de tableaux
  # call it like : show_cell_list(c.paquets) { |p| link_to_paquet(p) }
  def show_cell_list(list)
    out = '<td>'
    if list and not list.empty?
      list.each { |e| out << yield(e) + '<br />' }
    end
    out << '</td>'
  end

  # options : 
  #  * no_title : permet de ne pas mettre de titre à la liste
  #  * puce : permet d'utiliser un caractère qcq à la place des balises <liste>
  # Call it like : <%= show_liste(@correctif.binaires, 'correctif') {|e| e.nom} %>
  def show_liste(elements, nom, options = {})
    size = elements.size
    return "<u><b>Aucun(e) #{nom}</b></u>" unless size > 0
    result = ''
    unless options[:no_title]
      result << "<b>#{pluralize(size, nom.capitalize)} : </b><br/>"
    end
    if options[:puce]
      puce = " #{options[:puce]} "
      elements.each { |e| result << puce + yield(e).to_s + '<br/>' }
    else
      result << '<ul>'
      elements.each { |e| result << '<li>' + yield(e).to_s + '</li>' }
      result << '</ul>'
    end
    result
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
    titres.each {|t| result << "<th nowrap>#{t}</th>" }
    
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
    result << '</tr></table><br/>'
    result
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


  ### TIME #########################################################################

  #affiche le nombre de jours ou un "Sans objet"
  def display_jours(temps)
    return temps unless temps.is_a? Numeric
    case temps
    when -1 then "Sans objet"
    when 1 then "1 jour ouvré"
    else temps.to_s + " jours ouvrés"
    end
  end

  def display_seconds(temps)
    return temps #unless temps.is_a? Numeric
    # temps==-1 ? "sans engagement" : distance_of_time_in_french_words(temps) + " "
  end


  # déplacé depuis app/models/demande.rb
  # TODO : être DRY
  def time_in_french_words(distance_in_seconds)
    return '-' unless distance_in_seconds.is_a? Numeric and distance_in_seconds > 0
    distance_in_minutes = ((distance_in_seconds.abs)/60).round
    jo = 24.hours / 60 #/ 60 
    mo = 30 * jo
    demi_jo_inf = (jo / 2) - 60
    demi_jo_sup = (jo / 2) + 60

    case distance_in_minutes
    when 0
      " - "
    when 0..1 
      (distance_in_minutes==0) ? "moins d'une minute" : '1 minute'
    when 2..45 
      "#{distance_in_minutes} minutes"
    when 46..90  
      'environ 1 heure'
    when 90..demi_jo_inf, (demi_jo_sup+1)..jo 
      "environ #{(distance_in_minutes.to_f / 60.0).round} heures"
    when (demi_jo_inf+1)..demi_jo_sup
      "1 demie journée "
    when jo..(1.5*jo)
       "1 jour ouvré"
    # à partir de 1.5 inclus, le round fait 2 ou plus : pluriel
    when (1.5*jo)..mo
      "#{(distance_in_minutes / jo).round} jours"
    when mo..(1.5*mo)
       "1 mois ouvré"
    else
      "#{(distance_in_minutes / mo).round} mois"
    end
  end

  # conversion secondes en jours
  def sec2jour(seconds)
    ((seconds.abs)/(60*60*24)).round
  end
  # conversion secondes en minutes
  def sec2min(seconds)
    ((seconds.abs)/60).round
  end

  ### NON CLASSE ###################################################################



end
