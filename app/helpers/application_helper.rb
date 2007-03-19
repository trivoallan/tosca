#time_in_frenzezzrzrzrzzirhoahni'"o####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################

# Methods added to this helper will be available to all templates in the application.
# This is a big helper, so find by keyword :
# - LIENS ABSOLUS
# - LIENS RELATIFS
# - TEXTE
# - FILES
# - LISTES ET TABLES
# - TIME
module ApplicationHelper

  include ImagesHelper
  include PagesHelper
  include FormsHelper

  def search_demande(options = {})
    text_field('numero', '', 'size' => 3)
  end
  
  ### LIENS ABSOLUS ############################################################

  # lien vers un compte existant
  # DEPRECATED : préferer link_to_edit(id)
  # TODO : passer id en options, avec @session[:user].id par défaut
  # TODO : title en options, avec 'Le compte' par défaut
  def link_to_modify_account(id, title)
    return '' unless id
    options = {:action => 'modify', :controller => 'account', :id => id }
    link_to title, options
  end

  # lien vers mon offre / mon client
  # TODO options[:text] doit prendre l'image si options[:image]
  # options
  # :text texte du lien à afficher
  # :image image du client à afficher à la place
  def link_to_my_client(options = {:text => 'Mon&nbsp;Offre'})
    return nil unless session[:beneficiaire]
    if options[:image]
      link_to image_tag(url_for_file_column(
                  @beneficiaire.client.photo, 'image', 'thumb')),
                  :controller => 'clients', 
                  :action => 'show', :id => session[:beneficiaire].client_id
    else
      link_to options[:text], :controller => 'clients', 
                              :action => 'show', 
                              :id => session[:beneficiaire].client_id
    end
  end

  # lien vers la consultation d'UN logiciel
  def link_to_logiciel(logiciel)
      if logiciel
        link_to logiciel.nom, :controller => 'logiciels', 
                              :action => 'show', :id => logiciel.id
      else
        # cas où le logiciel n'existe pas/plus
        "logiciel inconnu"
      end
  end

  # lien vers la consultation d'UN groupe
  def link_to_groupe(groupe)
      link_to groupe.nom, :controller => 'groupes', 
                          :action => 'show', :id => groupe.id
  end

  # add_view_link(demande)
  def link_to_comment(ar)
      link_to image_view, { :controller => 'demandes', :action => 'comment',
        :id => ar}, { :class => 'nobackground' }
  end

  # une contribution peut être liée à une demande externe
  # le "any" indique que la demande peut etre sur n'importe quel tracker
  # TODO : verifier que le paramètre est une contribution
  def link_to_any_demande(contribution)
    return " - " if !contribution.id_mantis && contribution.demandes.size == 0
    out = []
    if contribution.id_mantis
      out << "<a href=\"http://www.08000linux.com/clients/minefi_SLL/mantis/view.php?id=#{contribution.id_mantis}\">
       Mantis ##{contribution.id_mantis}</a>"
    end
    contribution.demandes.each {|d|
      out << "#{link_to_demande(d, {:show_id => true, :pre_text => 'Lstm'})}"
    }
    out * '<br/>'
  end



  ### TEXTE #####################################################################

  # indente du texte et échappe les caractères html
  # à utiliser sur les descriptions, commentaires, etc
  def indent( text )
    (text.is_a? String) ? h(text).gsub(/[\n]/, '<br />') : text
  end

  # affiche un message d'aide
  # TODO : mettre une icône
  # TODO : en mettre plus dans les formulaires
  # TODO : changer le curseur en celui avec le '?'
  def show_help( help_text )
    "<a title=\"#{help_text}\" >?</a>"
  end

  ### FILES #####################################################################

  def file_size( file )
    (File.exist?(file) ? number_to_human_size(File.size(file)) : '-' )
  end

  # Call it like this : link_to_file(document, 'fichier', 'nomfichier')
  def link_to_file(record, file)
    if record and record.send(file) and File.exist?(record.send(file))
      nom = record.send(file)[/[._ \-a-zA-Z0-9]*$/]
      link_to nom, url_for_file_column(record, file, :absolute => true)
    else
      '-'
    end
  end


  ### LISTES ET TABLES ##########################################################

  # options :
  #  * no_title : permet de ne pas mettre de titre à la liste
  #  * puce : permet d'utiliser un caractère qcq à la place des balises <liste>
  # Call it like : 
  #   <%= show_liste(@contribution.binaires, 'contribution') {|e| e.nom} %>
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
  # <%= show_table(@documents, Document, titres) { |e| "<td>#{e.nom}</td>" } %>
  # N'oubliez pas d'utiliser les <td></td>
  # 2 options, :total et :content_columns
  # La première désactive le décompte total si positionné à false
  # La deuxième active l'affichage des content_columns si positionné à true
  # TODO : intégrer width et style dans une seule option
  def show_table(elements, ar, titres, options = {})
    return "<br/><p>Aucun #{ar.table_name.singularize} à ce jour</p>" unless elements and elements.size > 0
    width = ( options[:width] ? "width=#{options[:width]}" : "" )
    result = "<table #{width} class=\"show_table\">"

    if titres.size > 0
      result << '<tr>'
      if (options[:content_columns])
        ar.content_columns.each{|c| result <<  "<th>#{c.human_name}</th>"}
      end
      #On doit mettre nowrap="nowrap" pour que ça soit valide XHTML
      titres.each {|t| result << "<th nowrap=\"nowrap\">#{t}</th>" }
      result << '</tr>'
    end

    elements.each_index { |i|
      result << "<tr class=\"#{cycle('pair', 'impair')}\">"
      if (options[:content_columns])
        ar.content_columns.each {|column|
          result << "<td>#{indent elements[i].send(column.name)}</td>"
        }
      end
      result << yield(elements[i])
      result << '</tr>'
    }
    result << '</table><br/>'
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


  ### TIME ######################################################################

  #affiche le nombre de jours ou un "Sans objet"
  def display_jours(temps)
    return temps unless temps.is_a? Numeric
    case temps
    when -1 then "Sans objet"
    when 1 then "1 jour ouvré"
    when 0..1 then temps.to_s + " jour ouvré"
    else temps.to_s + " jours ouvrés"
    end
  end

  def display_seconds(temps)
    return temps #unless temps.is_a? Numeric
    # temps==-1 ? "sans engagement" : distance_of_time_in_french_words(temps) + " "
  end


  # DEPRECATED : fonction du meme nom appelee depuis lib/lstm.rb
  #def time_in_french_words(distance_in_seconds)
  #end

  # conversion secondes en jours
  def sec2jour(seconds)
    ((seconds.abs)/(60*60*24)).round
  end
  # conversion secondes en minutes
  def sec2min(seconds)
    ((seconds.abs)/60).round
  end

  ### NON CLASSE ################################################################

end
