#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################

# Methods added to this helper will be available to all templates
# in the application. Don't ever add a method to this one without a really good
# reason. Anyway, this is a big helper, so find by keyword :
# - TEXTE
# - FILES
# - LISTES ET TABLES
# - TIME


module ApplicationHelper
  include PagesHelper
  include FormsHelper
  include LinksHelper
  include ImagesHelper
  include FilesHelper


  ### TEXTE #####################################################################
  # indente du texte et échappe les caractères html
  # à utiliser sur les descriptions, commentaires, etc
  def indent( text )
    (text.is_a? String) ? h(word_wrap(text)).gsub("\n", '<br />') : text
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
    return '-' if file.blank? or not File.exists?(file)
    number_to_human_size(File.size(file))
  end

  ### LISTES ET TABLES ##########################################################
  # Display an Array of elements in a list manner
  # It takes a bloc in order to know what to display
  # Options :
  #  * :no_title : Set it to true for not displaying emphasis
  #  * :title : Set it to false.
  #  * :puce : allows to specify its own tag instead of '&lt;li&gt;'
  #  * :edit : name of the controllers needed to decorate list with
  #   an edit link and a delete link. Used widely in the show view of softwares.
  # If there is no block given, the field is displayed as is, with 'to_s' method.
  # Call it like :
  #   <%= show_liste(@contribution.binaires, 'contribution') {|e| e.nom} %>
  def show_liste(elements, nom = '', options = {})
    size = elements.size
    return '<u><b>' << _('No') << " #{nom}</b></u><br />" unless size > 0
    if !session.data.has_key?(:user) and !options.has_key?(:public)
      return "<u><b>#{pluralize(size, nom.capitalize)}" << _(' to date') << '</b></u><br />'
    end

    result = ''
    unless nom.blank? or options[:title]==false or options.has_key? :no_title
      result << "<b>#{pluralize(size, nom.capitalize)} : </b><br />"
    end

    # used mainly in bienvenue/about
    return show_simple_list(result, elements) unless block_given?

    # It can really be pretty ruby. We keep it under the hand 
    # until yarv comes and so this code will be reasonabily fast
    # yield_or_default = proc {|e| (block_given? ? yield(e) : e) }

    # TODO : remove this 'puce' option, change code using this options
    # and use CSS class instead.
    if options.has_key? :puce
      puce = " #{options[:puce]} "
      elements.each { |e|
        elt = yield(e)
        result << puce << elt << '<br />' unless elt.blank?
      }
    else
      result << '<ul>'
      edit = options[:edit]
      edit_call, delete_call = "edit_#{edit}_path","#{edit}_path" if edit
      elements.each { |e|
        elt = yield(e)
        unless elt.blank?
          result << '<li>'
          result << link_to_edit(send(edit_call, e)).to_s << ' ' if edit
          result << elt
          result << link_to_delete(send(delete_call, e)).to_s << ' ' if edit
          result << '</li>'
        end
      }
      result << '</ul>'
    end
    result
  end

  # Wrapper, allowing to have a consistent api with link_to_*
  # Call it like exactly show_liste
  def public_show_liste(elements, nom = '', options = {}, &functor)
    public_options = options.dup
    public_options[:public] = true
    show_liste(elements, nom, public_options, &functor)
  end

  # Private call, used by show_liste on certain simple case
  def show_simple_list(result, elements)
    result << '<ul>'
    elements.each { |e| result << "<li>#{e}</li>" unless e.blank? }
    result << '</ul>'
  end
  

  # Call it like :
  # <% titres = ['Fichier', 'Taille', 'Auteur', 'Maj'] %>
  # <%= show_table(@documents, Document, titres) { |e| "<td>#{e.nom}</td>" } %>
  # N'oubliez pas d'utiliser les <td></td>
  # 3 options
  #   :total > désactive le décompte total si positionné à false
  #   :content_columns > active l'affichage des content_columns si positionné à true
  #   :add_lines > affiche à la fin le tableau de lignes passé [[line1],[line2]]
  # TODO : intégrer width et style dans une seule option
  def show_table(elements, ar, titres, options = {})
    return '<p>' << _('No %s  at the moment') % ar.table_name.singularize + '</p>' unless elements and elements.size > 0
    width = ( options[:width] ? "width=#{options[:width]}" : '' )
    result = "<table #{width} class=\"show\">"
    content_columns = options.has_key?(:content_columns)

    if titres.size > 0
      result << '<tr>'
      if (content_columns)
        ar.content_columns.each{|c| result <<  "<th>#{c.human_name}</th>"}
      end
      #On doit mettre nowrap="nowrap" pour que ça soit valide XHTML
      titres.each {|t| result << "<th nowrap=\"nowrap\">#{t}</th>" }
      result << '</tr>'
    end

    elements.each_index { |i|
      result << "<tr class=\"#{cycle('pair', 'impair')}\">"
      if (content_columns)
        ar.content_columns.each {|column|
          result << "<td>#{elements[i].send(column.name)}</td>"
        }
      end
      result << yield(elements[i])
      result << '</tr>'
    }

    if (options.has_key? :add_lines)
      options[:add_lines].each {|line|
        result << "<tr>"
        line.each {|cell|
          result << "<td>#{cell}</td>"
        }
        result << "</tr>"
      }
    end
    result << '</table><br />'
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
    when -1 then _('None')
    when 1 then _('1 workday')
    when 0..1 then temps.to_s + _(' workday')
    else temps.to_s + _(' workdays')
    end
  end

  def display_seconds(temps)
    return temps #unless temps.is_a? Numeric
    # temps==-1 ? "sans engagement" : distance_of_time_in_french_words(temps) + " "
  end

  # conversion secondes en jours
  def sec2jour(seconds)
    ((seconds.abs)/(60*60*24)).round
  end
  # conversion secondes en minutes
  def sec2min(seconds)
    ((seconds.abs)/60).round
  end


  ### MENU #####################################################################

  # Display a simple menu (without submenu) from an array
  # a field may be add in the array, to select a ticket
  # Options
  #  * :form include all in a form_tag
  #  * :add_class specifie a class to overide .simple_menu style
  def build_simple_menu(menu, options={})
    return unless menu.is_a? Array
    menu.compact!
    class_name = options[:class] ||= 'simple_menu'
    out = ''
    out << '<div class="'+ class_name +'">'
    out << form_tag(demandes_url, :method => :get) if options.has_key? :form
    out << ' <ul>'
    menu.each { |e| out << "<li>#{e}</li>" }
    out << ' </ul>'
    out << '</form>' if options[:form]
    out << '</div>'
  end

  # Build a menu from a hash of 2 arrays : titles and links
  # TODO : move js to public/js folder
  # Need common.css #menu part and following js :
  # Call it like :
  # <% menu = {} %>
  #   <% menu[:titles], menu[:links] = [], [] %>
  #   <% menu[:titles] << 'Un groupe de lien' %>
  #   <% menu[:links] << [ link_to('Par ici'), link_to('Par là') ] %>
  # <%= build_menu(menu) %>
  def build_menu(menu, options = {})
    return unless menu[:titles].is_a? Array
    return unless menu[:titles].size == menu[:links].size
    prefix = 'smenu'
    out = ''
    out << "<script type=\"text/javascript\"><!--
    window.onload=montre;
    function montre(id) {
      var d = document.getElementById(id);
      for (var i = 0; i<=10; i++) {
        if (document.getElementById('smenu'+i)) {
            document.getElementById('smenu'+i).style.display='none';
        }
      }
      if (d) {d.style.display='block';}
    }
    //--></script>"
    out << '<div id="menu" onmouseout="javascript:montre(\'\');">'
    menu[:titles].each_index {|i|
      id = prefix + i.to_s
      out << "<div class=\"liste_menu\" onmouseover=\"javascript:montre('#{id}');\">"
      out <<   show_liste_menu(id, menu[:links][i], menu[:titles][i])
      out << '</div>'
    }
    out << '</div>'
  end

  # Display an menu item : a title + a link list
  # Called from build_menu
  def show_liste_menu(id, elements, titre, options = {})
    elements.compact!
    size = elements.size
    return '' unless titre.is_a? String
    result = ''
    result << "<div class=\"liste_title\">#{titre.humanize}</div>"
    return result unless size > 0 #and options[:sublink]
    result << "  <div class=\"liste_items\" id=\"#{id}\" >"
    result << '    <ul>'
    elements.each { |e| result << "<li>#{e}</li>" }
    result << '    </ul>'
    result << '  </div>'
  end


  ### INFORMATIONS #########################################################

  def show_notice
      "<div id=\"information_notice\" class=\"information notice\">
         <div class=\"close_information\" onclick=\"Element.hide('information_notice')\">" <<
         StaticImage::hide_notice << "</div>
         <p>" << flash[:notice] << "</p>
       </div>"
  end

  def show_warn
      "<div id=\"information_error\" class=\"information error\">
         <div class=\"close_information\" onclick=\"Element.hide('information_error')\">" <<
         StaticImage::hide_notice << "</div>
         <h2>" + _('An error has occured') + "</h2>
         <ul><li>" << flash[:warn] << "</li></ul>
       </div>"
  end

end
